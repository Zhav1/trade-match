// supabase/functions/process-swipe/index.ts
// Handles swipe action and creates swap on mutual likes

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Verify JWT
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const { swiper_item_id, swiped_on_item_id, action } = await req.json()

    // Validate input
    if (!swiper_item_id || !swiped_on_item_id || !action) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (!['like', 'skip'].includes(action)) {
      return new Response(JSON.stringify({ error: 'Invalid action' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Verify user owns the swiper item
    const { data: swiperItem, error: itemError } = await supabase
      .from('items')
      .select('user_id')
      .eq('id', swiper_item_id)
      .single()

    if (itemError || !swiperItem || swiperItem.user_id !== user.id) {
      return new Response(JSON.stringify({ error: 'You can only swipe with your own items' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Create swipe record
    const { error: swipeError } = await supabase
      .from('swipes')
      .insert({
        swiper_user_id: user.id,
        swiper_item_id,
        swiped_on_item_id,
        action
      })

    // Handle duplicate swipe
    let isDuplicate = false
    if (swipeError) {
      if (swipeError.code === '23505') {
        // Duplicate swipe - still check for match if it's a like!
        isDuplicate = true
        if (action !== 'like') {
          return new Response(JSON.stringify({ error: 'Already swiped on this item' }), {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          })
        }
        // For duplicate likes, continue to match check
      } else {
        throw swipeError
      }
    }

    // If not a like (and not duplicate), we're done
    if (action !== 'like' && !isDuplicate) {
      return new Response(JSON.stringify({ success: true, matched: false }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Check for mutual like
    const { data: reciprocal } = await supabase
      .from('swipes')
      .select('id')
      .eq('swiper_item_id', swiped_on_item_id)
      .eq('swiped_on_item_id', swiper_item_id)
      .eq('action', 'like')
      .single()

    if (!reciprocal) {
      return new Response(JSON.stringify({ success: true, matched: false }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // MATCH FOUND! Create swap with consistent ordering
    const item1 = Math.min(swiper_item_id, swiped_on_item_id)
    const item2 = Math.max(swiper_item_id, swiped_on_item_id)

    const { data: swap, error: swapError } = await supabase
      .from('swaps')
      .upsert({
        item_a_id: item1,
        item_b_id: item2,
        status: 'active'
      }, { onConflict: 'item_a_id,item_b_id' })
      .select()
      .single()

    if (swapError) throw swapError

    // Create notifications for both users
    const { data: items } = await supabase
      .from('items')
      .select('id, user_id, user:users(name)')
      .in('id', [item1, item2])

    if (items && items.length === 2) {
      const userA = items.find(i => i.id === item1)
      const userB = items.find(i => i.id === item2)

      await supabase.from('notifications').insert([
        {
          user_id: userA.user_id,
          type: 'new_swap',
          title: 'New Match!',
          message: `You matched with ${userB.user.name}`,
          data: { swap_id: swap.id }
        },
        {
          user_id: userB.user_id,
          type: 'new_swap',
          title: 'New Match!',
          message: `You matched with ${userA.user.name}`,
          data: { swap_id: swap.id }
        }
      ])
    }

    return new Response(JSON.stringify({ success: true, matched: true, swap }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in process-swipe:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})
