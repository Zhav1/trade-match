<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Item>
 */
class ItemFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        // List of realistic item statuses
        $statuses = ['active', 'exchanged', 'pending', 'inactive'];

        return [
            'user_id' => User::factory(),
            'title' => fake()->words(3, true),
            'description' => fake()->paragraphs(2, true),
            'cover_image_path' => 'items/' . fake()->uuid() . '.jpg',
            'status' => fake()->randomElement($statuses),
            'lat' => fake()->latitude(-6.9175, -6.9), // Jakarta area
            'lng' => fake()->longitude(106.8, 106.9), // Jakarta area
        ];
    }

    /**
     * Indicate that the item is active.
     */
    public function active(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'active',
        ]);
    }

    /**
     * Indicate that the item has been exchanged.
     */
    public function exchanged(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'exchanged',
        ]);
    }
}