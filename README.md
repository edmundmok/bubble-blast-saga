CS3217 Problem Set 5
==

**Name:** Mok Wei Xiong, Edmund

**Matric No:** A0093960X

**Tutor:** Delon Wong

# Note to self
> Also, clean up my code for LogicSim (hint related).
> 
Sprites taken from:
1. Explosion: http://opengameart.org/content/pixel-explosion-12-frames
2. Lightning: https://www.reddit.com/r/gamedev/comments/2rw8ya/1000_free_2d_sprites_animations_tiles_and_effects/
3. Star image: http://opengameart.org/content/star
> Sounds:
> 1. Thunder: http://freesound.org/people/Erdie/sounds/24003/
> 2. Explosion:
> 3. Star: 

### Rules of Your Game

Your answer here


### Problem 1: Cannon Direction

The user may use either a *Long Press* or *Pan Gesture* to select the cannon direction. Pressing anywhere on the game area (which is the entire screen) will activate the *Long Press* Gesture recognizer, and the cannon will immediately turn to face the direction of the user's finger. If that is not enough, the user can then pan around the screen with his finger, and the cannon will automatically follow the user's finger so that the user can define a more accurate direction to fire in. Once the user is satisfied with the cannon angle, he may simply release his finger from the screen and the bubble is fired at the direction his finger was last present at (before release).


### Problem 2: Upcoming Bubbles

My algorithm will generate the next bubble based on "luck". For example, if the player selects the best luck rating, 60% of the time he will be given the bubble color that he needs (which is the color that occurs most frequently in the grid at the point of generating the bubble). The other 40% of the time he will be given a random bubble color.

The rationale behind this is that if I just use completely random colors it might be hard for the player to end the game. By generating a color that he may need, but with a certain luck percentage, it will be more fair for the player and I can also make it more challenging by providing different luck ratings to choose from so the player can choose from different difficulties. 

I am planning to display the current bubble, as well as the next upcoming bubble.

### Problem 3: Integration

#### How my design allowed the integration

My design for the Level Designer side and Game Engine side both use the same underlying BubbleGridModel / BubbleGridModelManager. As such, when the user presses the **START** button, I just need to segue from the Level Designer View Controller to the Game View Controller and in the process pass the same underlying BubbleGridModel from the LevelDesignerViewController to the GameViewController. As the GameViewController loads up, it will then load the model received by the LevelDesigner into the Game Engine, and then start the game engine, so that the bubbles in the bubble grid are in the game engine, and can be interacted with as physics objects and rendered on screen. 

In short, I only had to pass my model to my game view controller, and created another method to iterate through the model and each bubble in the bubble grid to the game engine.  

#### What are the alternative approaches?
1. 

#### Advantage vs alternative approaches
1. 


#### Disadvantage vs alternative approaches
1. 

### Problem 4.3

*(Just realised this part is only 5 points, enjoy the read :D)*

#### Strategy in implementing special bubble behavior

Previously, upon a collision and the bubble snapping into place, the logic would then handle the interactions between the newly snapped bubble and its adjacent neighbours (basically just checking if there are connected bubbles to remove). 

Now, with special bubbles, I just need to add an activation function `activateSpecialBubbles(near: coloredBubble)` to be called at the start of the interaction handling function. Basically, I will handle any interactions with nearby special bubbles first, before handling any removal of connected bubbles with the same color.

This special bubbles activating function will then seek out the adjacent special bubbles, and activate each adjacent bubble by using a generic `activateSpecialBubble(at indexPath: IndexPath, with activatingBubble: GameBubble)` method. The method will check the type of special bubble and call the appropriate helper method. 

Each type of special bubble will have its own helper method, for example: `activate(lightningBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: GameBubble)`, `activate(bombBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: GameBubble)` and `activate(starBubble: PowerBubble, at indexPath: IndexPath, with activatingBubble: GameBubble)`. The reason we need the activating bubble is for chaining behavior, described in the section below, **About the chaining behavior**. The appropriate behavior for each special bubble is then implemented in each of the helper functions respectively. 

My strategy for the chaining is to recursively call my `activateSpecialBubble(at indexPath: IndexPath, with activatingBubble: GameBubble)` method. An example: User shoots a projectile at a **Lightning Bubble**. **Lightning Bubble** activates, destroying the row it is on. This also destroys a **Bomb bubble** on the same row. **Bomb bubble activates**, destroying adjacent bubbles. What my implementation will do is first check for special bubbles around the projectile bubble when it is snapped into place. After that, for each special bubbles beside it, activate them. Once activated, depending on the **power / ability** of the special bubble, it will have a list or set of index paths of bubbles in the grid to remove. For each index path, I will check whether it is a special bubble and if it is, activate it by calling `activateSpecialBubble(at indexPath: IndexPath, with activatingBubble: GameBubble)` on that special bubble at that index path. This will carry out the chaining recursively. Furthermore, I only remove these bubbles at the indexpaths found only after I attempt to chain, because if you remove first then you can't actually chain!

#### Why my strategy is the best among alternatives

1. It is easy to add more special bubble behaviors by just adding a new helper method for that new type of special bubble.
2. Existing code handling the removal of colored bubbles does not have to modified, and can be reused as we simply just have to package it in a method called 	`handleColoredInteractions(with: coloredBubble)` to be  called after we handle special bubbles first.
3. An alternative is handling colored bubble removals first, but this might lead to cases where the behavior might not be expected. For example, let's say we have a section of all blue bubbles, except the first bubble is a bomb bubble. If the user shoots at the bomb and it lands just below the bomb bubble, his intention is to activate the bomb. So if the removal of colored bubble is handled first, the entire row would be removed and the bubble that was shot is also removed. Then the bomb is never activated. As such I give special bubbles a higher priority. Of course, you can also argue the other end where the user is trying to pop the connected row instead of the bomb. In that case, my approach would not give the desired result. Another alternative is to not actually remove that bubble affected by the bomb, so that the connected bubbles will be removed also. But actually, this will look weird on the screen because the bomb animation will destroy the adjacent bubbles, yet it still remove connected bubbles with the destroyed bubble. To handle this dilemma, I simply give higher priority to special bubbles, because they are after all *special bubbles*.
4. Recursion might not be the most efficient way to handle this, especially in **extreme** settings like the entire grid is filled with bombs. However, it is the simplest way to implement the chaining right now, and I can't think of a better alternative that is as neat.


#### About the chaining behaviour

The problem set description does not define a way to handle what happens in the case a **Star Bubble** is **destroyed** by another **Special Bubble (in this case, either another Lightning, Bomb or Star)**. 

As such, I have decided to make it such that original colored bubble fired from the cannon, that initiated the chain in the first place, that activated the Star Bubble is the one that the it will follow to remove from the bubble grid. For example, if we shot a Red bubble, which activated a lightning bubble destroys its row, and in the process, destroyed a Star bubble, the Star Bubble will remove all Red bubbles as it was the color that started the chain, and so it is as if the Red bubble was the one who activated it (although indirectly).

Another question arises: This will activate all the special bubbles around the snapped projectile bubble, but it can only activate one at a time. What if there are cases where the order in which we activate the bubbles makes a difference?

Here is such a case: There is a **Lightning bubble**, an empty space, and then a **Star bubble**. The user shoots the projectile between the two, landing in between. 

With my current approach, the order which we activate will not be a problem since if we activate the lightning first, we would propagate the original color bubble color to the star, thus activating the star with the original color. If we activate the star first, the star removes all of that color and activates the lightning. In any case, both will lead to the same result.

This is in contrast with an alternative where we activate the star based on whatever bubble was the one who "hit" it. E.g. if lightning hit it, then star will activate all lightning in the grid. This might seem cooler but can cause problems due to activation order, as mentioned in the scenario above. There will be different results depending on whether we activate the lightning or the star first.

### Problem 7: Class Diagram

Please save your diagram as `class-diagram.png` in the root directory of the repository.

### Problem 8: Testing

Your answer here


### Problem 9: The Bells & Whistles

1. **Added a trajectory animation and path to the cannon.** While the user is taking aim, the path of the bubble will be projected so that the user can fine tune his aim. Modification made: Need to use the physics engine to manually step through for the special trajectory bubble and after each step add its position to an array of points. Then when the bubble stops, or after a limit is reached on the number of points, draw a bezier path connecting those points.
2. **Added bubble bursting animation when bubbles are popped.** For this, I realised my classes that did the animation previously were a bit restrictive as I only took into account animations using `UIView.animateWithDuration(...)`. The bubble bursting animation required the use of a UIImageView's animationImages instead. Previously, my `Renderer` was doing the animations, and I had an `AnimationHelper` that generates the *animation code block* that is used in the `UIView.animateWithDuration(...)` method. As you can see it only takes into account a certain type of animation using the UIView but cannot use the `UIImageView`'s animationImages property. So I had to reorganize my animation code and create a `BubbleGameAnimator` class for `BubbleGameLogic` to know about and call whenever an animation needs to be done due to logic stuff. `BubbleGameAnimator` will then execute the appropriate animation accordingly. `BubbleGameAnimator` is able to execute both types of animations that I mentioned before. I feel that this change is good as these animations are a bit *game-specific* for the `Renderer` to know about so having a `BubbleGameAnimator` do these instead of a `Renderer` doing these feels abit more cohesive, and also the `Renderer` more reusable.
3. **Added an advanced hint system to inform user of best case position for the bubble to be to maximize bubbles removed.** This is an improved version of the previous system, that actually does simulation of the outcomes for each candidate positions of the basic system. It then reveals the best position for the current bubble to be in. A consideration is that there is a *thinking time* incurred to decide which is the best position due to running simulations. In order to prevent lag to the game, I used async calls for the hints so that the UI will never appear laggy. Although, this would mean that there might be a little delay in the computation of the hint.
4. **Added game score.** The score is shown at the bottom of the screen, below all the bubbles. Each bubble removed will contribute to the score with a base score, and the score will be boosted based on the current streak of the player and the combo of the player.
5. **Added retry and back button in game view.** *Retry button* allows the player to restart the level and attempt the level again from the start. *Back button* allows the player to go back to the previous screen he came from (e.g. he started from Level Designer, so go back to Level Designer).
6. **Added game end conditions depending on game modes.**
	* Limited shots
		* Player starts out with a limited amount of bubbles to shoot. The game ends when the player runs out of bubbles to shoot - if there still exists bubbles in the grid, he loses, else he wins; or if the bubble grid becomes empty at any point in the game. Furthermore, If a bubble reaches the bottom section of the grid at any point in the game, player will lose.
	* Limited time
		* Player has unlimited shots to fire, but can only play for a certain time limit for the level. After the time limit expires, the game will end, and depending on whether there are still bubbles in the grid, the player wins or loses. If the bubble grid becomes empty at any point in the game, the player will win.
7. **Added end game screen.** The end game screen displays the game outcome and the game score. The retry and back button also move to the center of the screen for easy access. The end game screen also shows some simple statistics for the player for that level. These include the best combo the player achieved, the lucky color for the player (the colored bubble which led to the best combo), the best chain count achieved, the best removal streak and the accuracy of the player.
8. **Added effects for lightning, bomb and star bubble.** For lightning, a lightning bolt will be flashed across the screen along the section of the grid where the lightning bubble was. For bomb bubble, an explosion effect will be generated around the location of the bomb bubble. For the star bubble, a glowing star will be generated at the locations of all colored bubbles to be removed due to the star.
9. **Added validation check for level designer.** User will not be allowed to start or save the level unless it is valid.
10. 


### Problem 10: Final Reflection

Your answer here
