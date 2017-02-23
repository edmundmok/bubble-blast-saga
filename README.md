CS3217 Problem Set 5
==

**Name:** Mok Wei Xiong, Edmund

**Matric No:** A0093960X

**Tutor:** Delon Wong

# Note to self
> Fix my chaining of star bubble. Either carry forward the original bubble to chain to the star, or continue with current implementation to activate all lightning bubbles. But there will be a problem as described below.
> Also, clean up my code for LogicSim (hint related).

### Rules of Your Game

Your answer here


### Problem 1: Cannon Direction

The user may use either a *Long Press* or *Pan Gesture* to select the cannon direction. Pressing anywhere on the game area (which is the entire screen) will activate the *Long Press* Gesture recognizer, and the cannon will immediately turn to face the direction of the user's finger. If that is not enough, the user can then pan around the screen with his finger, and the cannon will automatically follow the user's finger so that the user can define a more accurate direction to fire in. Once the user is satisfied with the cannon angle, he may simply release his finger from the screen and the bubble is fired at the direction his finger was last present at (before release).


### Problem 2: Upcoming Bubbles

As of now, my algorithm for deciding the colors of the next few bubbles is to just generate a random number and get the associated colored bubble according to that random number. Effectively, the upcoming bubbles will be randomly generated.

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

Another question arises: This will activate all the special bubbles around the snapped projectile bubble, but it can only activate one at a time. What if there are cases where the order in which we activate the bubbles makes a difference?

Here is such a case: There is a **Lightning bubble**, an empty space, and then a **Star bubble**. The user shoots the projectile between the 2, landing in between. 

#### Why my strategy is the best among alternatives

1. It is easy to add more special bubble behaviors by just adding a new helper method for that new type of special bubble.
2. Existing code handling the removal of colored bubbles does not have to modified, and can be reused as we simply just have to package it in a method called 	`handleColoredInteractions(with: coloredBubble)` to be  called after we handle special bubbles first.
3. An alternative is handling colored bubble removals first, but this might lead to cases where the behavior might not be expected. For example, let's say we have a section of all blue bubbles, except the first bubble is a bomb bubble. If the user shoots at the bomb and it lands just below the bomb bubble, his intention is to activate the bomb. So if the removal of colored bubble is handled first, the entire row would be removed and the bubble that was shot is also removed. Then the bomb is never activated. As such I give special bubbles a higher priority. Of course, you can also argue the other end where the user is trying to pop the connected row instead of the bomb. In that case, my approach would not give the desired result. Another alternative is to not actually remove that bubble affected by the bomb, so that the connected bubbles will be removed also. But actually, this will look weird on the screen because the bomb animation will destroy the adjacent bubbles, yet it still remove connected bubbles with the destroyed bubble. To handle this dilemma, I simply give higher priority to special bubbles, because they are after all *special bubbles*.
4. Recursion might not be the most efficient way to handle this, especially in **extreme** settings like the entire grid is filled with bombs. However, it is the simplest way to implement the chaining right now, and I can't think of a better alternative that is as neat.


#### About the chaining behaviour

The problem set description does not define a way to handle what happens in the case a **Star Bubble** is **destroyed** by another **Special Bubble (in this case, either another Lightning, Bomb or Star)**. 

As such, I have decided to make it such that whatever is the last thing that activated the Star Bubble is the one that the it will follow to remove from the bubble grid. For example, if a lightning bubble destroys its row, and in the process, destroyed a Star bubble, the Star Bubble will remove (and activate) all lightning bubbles in the grid (whihc makes sense, since it is the one that caused the star bubble to activate its ability).

This also brings up another point, in the problem set it only says **star bubbles** remove the *ALL* bubbles with the appropriate color from the grid. However, with my approach, then the **star bubbles** will **"remove" special bubbles** from the grid. In this case, I think it would be more exciting not just to **"remove"** them, but **activate** them as well. This would allow a higher skill ceiling as users can plan their shots to chain lightnings or bombs with the star, and activate even more lightnings and bombs as a result.

### Problem 7: Class Diagram

Please save your diagram as `class-diagram.png` in the root directory of the repository.

### Problem 8: Testing

Your answer here


### Problem 9: The Bells & Whistles

1. **Added a trajectory animation and path to the cannon.** While the user is taking aim, the path of the bubble will be projected so that the user can fine tune his aim. Modification made: Need to use the physics engine to manually step through for the special trajectory bubble and after each step add its position to an array of points. Then when the bubble stops, or after a limit is reached on the number of points, draw a bezier path connecting those points.
2. **Added bubble bursting animation when bubbles are popped.** For this, I realised my classes that did the animation previously were a bit restrictive as I only took into account animations using `UIView.animateWithDuration(...)`. The bubble bursting animation required the use of a UIImageView's animationImages instead. Previously, my `Renderer` was doing the animations, and I had an `AnimationHelper` that generates the *animation code block* that is used in the `UIView.animateWithDuration(...)` method. As you can see it only takes into account a certain type of animation using the UIView but cannot use the `UIImageView`'s animationImages property. So I had to reorganize my animation code and create a `BubbleGameAnimator` class for `BubbleGameLogic` to know about and call whenever an animation needs to be done due to logic stuff. `BubbleGameAnimator` will then execute the appropriate animation accordingly. `BubbleGameAnimator` is able to execute both types of animations that I mentioned before. I feel that this change is good as these animations are a bit *game-specific* for the `Renderer` to know about so having a `BubbleGameAnimator` do these instead of a `Renderer` doing these feels abit more cohesive, and also the `Renderer` more reusable.
3. **Added a simple hint system to inform user of possible locations to shoot at.** This system only hints at possible locations to shoot at, not actually checking which location can maximize the result. The result is that it will be quite laggy. For this simple hint system, I only needed to identify all the exposed bubbles (bubbles that can be reached somehow) and check if the neighbour is a special bubble or same color as the current cannon bubble. If any of these are true, the position is possible hint position.
4. **Added an advanced hint system to inform user of best case position for the bubble to be to maximize bubbles removed.** This is an improved version of the previous system, that actually does simulation of the outcomes for each candidate positions of the basic system. It then reveals the best position for the current bubble to be in. A consideration is that there is a *thinking time* incurred to decide which is the best position due to running simulations. If the game is still going on, it might appear laggy to the user. **Possible counter, to be finalized: Only able to use hint when no bubbles are flying, and display a thinking popup or something so that user cannot do anything when the system is thinking. This will "hide" the lagginess that will be perceived if the game is still ongoing while the thinking process is being executed (moving projectiles and the rotation of cannon might appear laggy).**
5. **Added game score.**


### Problem 10: Final Reflection

Your answer here
