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

Colored bubbles work as per previous PS.

Special bubble interactions are as follows:

1. Indestructible bubble cannot be destroyed, can only be removed by dropping
2. Lightning bubbles destroy all in the same section of the bubble grid, and activate any special bubbles in that section
3. Bomb bubble destroys all adjacent bubbles around it, and activates any adjacent special bubbles around it
4. Star bubble destroys all colored bubbles from the grid that has the same color as the bubble that initiated the entire chain. The star bubble is either activated directly, or indirectly. If directly, due to collision with by a colored bubble, then all colored bubbles with the same color as that colored bubble are removed. If indirectly, due to a chaining effect, causing a lightning or a bomb to activate the star, then the original colored bubble that initiated the chain will be used to determine which color to remove.

If a bubble lands at the bottom section of the grid, the player will lose. However, if the bubble lands at the bottom section but was removed right after, e.g. due to interactions with special bubble or connected removal, then the player will not be penalized for it. This allows the player to strategically launch bubbles at the last section, while also making the game more forgiving at the same time.

### Problem 1: Cannon Direction

The user may use either a *Long Press* or *Pan Gesture* to select the cannon direction. Pressing anywhere on the game area (which is the entire screen) will activate the *Long Press* Gesture recognizer, and the cannon will immediately turn to face the direction of the user's finger. If that is not enough, the user can then pan around the screen with his finger, and the cannon will automatically follow the user's finger so that the user can define a more accurate direction to fire in. Once the user is satisfied with the cannon angle, he may simply release his finger from the screen and the bubble is fired at the direction his finger was last present at (before release).


### Problem 2: Upcoming Bubbles

My algorithm will generate the next bubble based on "luck". 40% of the time he will be given the bubble color that he needs (which is the color that occurs most frequently in the grid at the point of generating the bubble). The other 60% of the time he will be given a random bubble color.

In my game, I display the current bubble, as well as the next upcoming bubble.

### Problem 3: Integration

#### How my design allowed the integration

My design for the Level Designer side and Game Engine side both use the same underlying BubbleGridModel / BubbleGridModelManager. As such, when the user presses the **START** button, I just need to segue from the Level Designer View Controller to the Game View Controller and in the process pass the same underlying BubbleGridModel from the LevelDesignerViewController to the GameViewController. As the GameViewController loads up, it will then load the model received by the LevelDesigner into the Game Engine, and then start the game engine, so that the bubbles in the bubble grid are in the game engine, and can be interacted with as physics objects and rendered on screen. The game view controller will make a copy of the original model and load that copy into the game. This facilitates the reset, and so that the grid is not modified directly to preserve the level designer's grid.

In short, I only had to pass my model to my game view controller, and created another method to iterate through the model and each bubble in the bubble grid to the game engine. Also, to create a copy I just had to add some methods in the bubble grid to create a copy of itself using the same references.

#### What are the alternative approaches?
1. An alternative approach would be to create an exact copy of the entire model (not just a copy of the references)

#### Advantage vs alternative approaches
1. Simply copying the references would be much faster and more efficient


#### Disadvantage vs alternative approaches
1. My approach works great for now, because my game does not actually modify any attributes of the bubbles in the bubble grid. As such, we only need the references to the same objects and it will work the same. However, if I will ever need to modify the attributes of the bubbles in the bubble grid, then my approach cannot work anymore.

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

**Black-box testing:**

- Level Designer
	- Test implementation of file operations
        1. Save
            - Save file with new filename
            - Save file with filename that already exists
            - Save when the current grid is not a loaded/saved grid (a new grid)
            - Save when the current grid is a loaded/saved grid (not a new grid)
            - Save with filename that already exists and choose to overwrite
            - Save empty grid
            - Save a fully filled grid
            - Save a partially filled grid
            - Save grid where bubbles are at the edges (edge cases)
            - Save grid with bubbles in last section
            - Save grid with floating bubbles
        2. Load
            - Load existing file
            - Load empty grid
            - Load a fully filled grid
            - Load a partially filled grid
            - Load grid where bubbles are at the edge (edge cases)
        3. Delete
            - Delete existing level
    - Test implementation of level designer:
        1. Select palette bubble
            - Test default palette bubble when level designer first loads
            - Test select any palette bubble, selected bubble should show
              selected style, all other palette buttons should be grayed out
        2. Reset button
            - Reset empty grid remains empty
            - Reset partially filled grid empties the grid
            - Reset fully filled grid empties the grid
        3. Start button
            - Does nothing for now
        4. Save button
            - Any time this is pressed, should open the save level alert
               - More detailed tests described in the file operations tests
            - If current grid is not a loaded/saved grid, alert should ask for level name to save as.
            - If current grid is a loaded/saved grid, alert should ask if want to overwrite or save as a new level.
            - Test alphanumeric name
            - Test non-alphanumeric name
        5. Load button
            - Any time this is pressed, should segue to the level selection screen and display all saved levels
            - Single tap on a saved level to load that level in the level designer
            - Trash can icon to delete the level (with alert that pops up)
            - Test that level is not deleted if user does not cancels deletion during alert
            - Test that level is indeed deleted if user confirms deletion during alert
            - Back button on the navigation bar to go back to level designer
        6. Single tap gesture
            - On palette
                - Selects the desired palette button
            - On Grid cells
                - Erase mode selected
                    - Tap on empty cell remains empty
                    - Tap on filled cell empties cell
                - Any other palette mode selected
                    - Tap on empty cell fills cell with selected bubble color
                    - Tap on filled cell toggles bubble color through fixed cycle
        7. Long press gesture
            - Empty cell no change
            - Filled cell will be removed
            - Long press then pan > allows user to erase as though erase bubble is selected
        8. Pan gesture
            - Erase mode
                - Pan over empty cell no change
                - Pan over filled cell removes cell
            - Any other palette mode selected
                - Pan over empty cell fills cell with selected bubble
                - Pan over filled cell fills cell with selected bubble
	    9. Back button
		    - Goes back to the previous screen (main menu screen)
		    - After going back, click level designer again and the grid should not be filled (should be a fresh grid)
- Main Menu
	1. Play button
		- Test leads to level selection screen
	2. Design button
		- Test leads to level designer screen
- Game
	- Unit-testing
		1. Physics Engine
			- Test collision between two physics circles is detected
			- Test collision between a physics circle and a physics box is detected
			- Test collision between two physics boxes is detected
		2. Renderer
			- Draws image correctly at the right position
		3. Game Engine
			- Register a gameObject adds the game object to the game world
			- Register a gameObject with associated image adds the object with an associated image to the game world
			- Deregister a gameObject removes the game object and its associated image (if any) from the game world
		4. Game Object
			- update returns false if object has zero velocity
			- update returns true if object has non-zero velocity
			- position is updated correctly based on the velocity
		5. Queue 
			- This queue was taken from PS1, so basically all the tests from there
			- testEnqueue: enqueue correctly into queue of size 0, 1 and something > 2 (e.g. 5)
			- testDequeue: dequeue correctly from queue of size 0 (throw error), 1 and something > 2
			- testPeek: peek correctly into queue of size 0 (throw error), 1 and something > 2
			- testCount: returns correct count for queue of size 0, 1 and something > 2
			- testIsEmpty: returns true/false correctly for queue of size 0, 1 and something > 2
			- testRemoveAll: empties the array correctly for queue of size 0, 1 and something > 2
			- testToArray: returns a correct arrray representation for queue of size 0, 1, and something > 2
			- Test a combination of the above operations in random order so that the operations work well together
	- Integration-testing
		- Test gestures
			- Touching the screen changes the angle to point at the finger location immediately
			- Touching the screen causes a trajectory path to be drawn in the direction of touch
			- Pan gestures allow the user to specify the angle as the user pans
			- On release of the touch/pan, cannon should fire in the direction of the release
		- Test movable bubbles
			- Test bubble moves in a straight line
			- Test bubble moves at a constant speed
			- Test bubble moves in the direction of the cannon
			- Test bubble moves at same speed regardless of cannon angle
		- Test collisions between two bubbles
			- Test collision between a stationary bubble and a moving bubble
				- Should snap to position, removing any connected group of size >= 3 starting from that bubble, remove floating bubbles (more details below)
			- Test collision between two moving bubbles
				- Collision should have an elastic collision effect, bouncing the bubbles off each other
				- Test that the bubbles do not get stuck in collision
		- Test collisions between a bubble and a screen edge
			- Test collision between a bubble and side edge
				1. Test collision between bubble and left edge should bounce
				2. Test collision between bubble and right edge should bounce
			- Test collision between a bubble and the top edge
				- Collision is detected and bubble is snapped into the nearest empty cell (more details below)
				- Once snapped, if there exists a group of >= 3 bubbles starting from the newly added bubble with the same color, this entire group is removed from the grid (further testing for this below)
				- After that, if this results in floating bubbles in the grid, they must be dropped (further testing for this below)
			- Test collision between a bubble and the bottom edge
				- Test that the bubble is removed from the game
		- Test removal of connected bubbles
			- Test that the newly added bubble is removed when it forms a connected group of bubbles
			- Test that the connected group of bubbles are removed have the same color
			- Test that the connected group must be direct neighbours (must be connected), no indirect neighbour is removed
			- Test that the group is at least size 3
		- Test dropping of floating bubbles
			- Floating bubbles fall downwards to the bottom of the screen
			- Test that the bubbles that fall downwards do not interfere with the next projectile cannon bubble shot by the user
		- Test special bubbles
			- Test lightning bubbles
				- Test that a lightning sprite is displayed when the lightning bubble is activated
				- Test that all bubbles in the same section of the lightning bubble is removed or activated if it is a special bubble
				- Test that it does not affect indestructible bubble
				- Test that the bubble that collided with the lightning is destroyed if it collided in the same section as the lightning bubble
			- Test bomb bubbles
				- Test that a explosion sprite is displayed when the bomb is activated
				- Test that all adjacent bubbles are destroyed except indestructible bubbles
				- Test that the bubble that collided with the bomb is destroyed (if any)
			- Test indestructible bubbles
				- Test that no other chain effects will affect this bubble
				- Test that no other special bubbles will affect this bubble
				- Test that this bubble can be dropped once it becomes a floating bubble
			- Test star bubbles
				- Test that a star effect is generated on all colored bubbles that it removes
				- Test that the star activated will destroy all colored bubbles as the one who initiated the chain at the start
				- Test that the bubble that collided with the star is destroyed (if any)

**Glass-box testing**

- LevelDesigner
	- Test implementation of file operations
	    - Save and Load
	        - Check that a .bubblegrid file is created in the directory with the given name
	        - Check that the saved .bubblegrid file can be loaded properly
	        - Loading the saved .bubblegrid file does not delete the file
	- BubbleGridModelManager
	    - getIndex(from indexPath: IndexPath)
	        - Check the index for bubbles at the edges section 0
	        - Check the index for bubbles at the centre area for section 0
	        - Check the index for bubbles at the edges section 1
	        - Check the index for bubbles at the centre area for section 1
	        - Check the index for bubbles at the edges section 2 onwards
	        - Check the index for bubbles at the centre area for section onwards
	        - Check for different grid sizes
	- LevelDesignerViewController
	    - Bubblegrid Collection View
	        - Check that the grid bubbles are tightly packed
	        - The even rows have 12 bubbles and are nicely arranged
	        - The odd rows have 11 bubbles and are offset from the left and right by roughly half a bubble size each
	        - Save and then load a different grid size from the current grid and check that grid bubbles are still arranged neatly (not really a requirement of this PS)
	    - Gesture
	        - Check that the cycle order is: Blue > Red > Orange > Green  > Blue > ...
	        - Check that the long press gesture takes 0.5s press time before it erases the bubble in the cell
	    - Reset button
	        - Correctly clears the grid on the screen and the backing array of GameBubbles
	        - Reset does not affect the backing file the bubble grid was loaded from, if any
	- SaveAlertController
	    - Save confirmation for text field should only enable if name is alphanumeric and non-empty
	    - Check that no memory cycle is created
	        - Consecutive "save" then cancel do not increase memory usage
	        - Consecutive overwrite saves do not increase memory usage
	        - Consecutive save as new level saves do not increase memory usage
	        - Some combination of the above
	    - If not on a saved/loaded grid, alert will request user to enter name to save as.
	    - If on a saved/loaded grid, upon attempt to save, alert should know the current file name to save as to overwrite
	    - If on a saved/loaded grid, and load a different grid, alert should know the new file name to save as to overwrite
	    - Check that the image of the bubble grid is saved as a png with the same name as the level name chosen
	- SavedLevelsModelManager
	    - Check that the names of all the bubblegrid files in the directory are loaded into the savedLevels array
	    - Check that deleteLevelAt(index: Int) on invalid index (out of range of array)
	    - Check deleteLevelAt(index: Int) removes the String from the array and also removes the bubblegrid file of the same name from the directory
- Game
	- Unit-testing
		1. Physics Engine
			- Test collision between two physics circles is detected
				- Test circles of different radii
				- Test circles of same radii
			- Test collision between a physics circle and a physics box is detected
				- Test circle and square box
				- Test circle and rectangle box 
				- Test circle radius larger than box length
				- Test circle radius smaller than box length
			- Test collision betwen two physics boxes is detected
				- Test box of different size
				- Test box of same size
		2. Renderer
			- Drawing image for a physics circle object draws the image at the right position
			- Drawing image for a physics box object draws the image at the right position
			- Register image for a game object adds the image to the current canvas and to the imageMap
			- Deregister image for a game object removes the image from the current canvas and from the imageMap
			- Draw draws all the images of the game objects at their right position
		3. Game Engine
			- startGameLoop starts the loop timer and calls the mainLoopBody at an interval according to the gameSettings timeStep
			- Register a gameObject adds it to the gameObjects array
			- Register a gameObject with an associated image adds it to the gameObjects array (and the renderer's imageMap)
			- Deregister a gameObject removes it from the gameObjects array(, and removes the object's associated image from the renderer's imageMap if necessary)
		4. Game Object
			- update returns false if object has zero velocity
			- update returns true if object has non-zero velocity
			- position x and y is changed by velocity's dx and dy respectively
	- Integration-testing
		- Test gestures
			- Long press gesture should take 0 seconds to activate
			- Test able to pan and longpress simultaneously (e.g. long press first the cannon angle changes to finger, while finger is pressed, start panning around and the cannon angle follows the finger)
		- Test movable bubbles
			- Test all bubbles fired should move at the same speed
			- Movable bubbles should have a smaller collision size than their image (65% of the image size)
		- Test collisions between two bubbles
			- Test collision between a stationary bubble and a moving bubble
				- Moving bubble stops upon collision
				- Stationary bubble is unaffected by the collision unless due to game logic of connected bubble removal or floating bubble removal
			- Test collision between two moving bubbles 
				- Both bubbles unaffected by this collision as our game logic ignores two moving bubbles colliding (since it will not happen in the real game anyway)
		- Test collisions between a bubble and a screen edge
			- Test collision between a bubble and side edge
				- Test collision between bubble and left edge or right edge
					- Should reflect off at the same speed it collided with the edge, and move off at an equal outgoing angle in the opposite direction
					- Velocity dy component should be unchanged, dx is inverted (negative -> positive / positive -> negative)
			- Test collision between a bubble and the top edge
				- Moving bubble should stop upon collision
				- Moving bubble is not reflected like a side edge behavior
				- Moving bubble should snap to nearest empty top section cell in terms of closest distance to the empty cell centers
				- Test that bubbles that snap to the top section do not "collide" with the top edge again
				- Test that stationary bubbles at the topmost section initially are not constantly "colliding" with the top edge
		- Test removal of connected bubbles (starting from some newly added bubble)
			- Test total group of connected bubbles size 1 - nothing happens
				- Test no neighbour bubbles of the newly added bubble same color as it
				- Test no neighbour bubbles of newly added bubble same color as it, but the neighbour of neighbour form a connected group of size 2 with same color as it - it should not trigger a pop because they are not directly connected as neighbours
			- Test total group of connected bubbles size 2 - nothing happens
			- Test total group of connected bubbles size 3 - Bubbles popped with animation
			- Test total group of connected bubbles size 4 - Bubbles popped with animation
			- Test total group of connected bubbles size > 4
			- Test positions where the bubbles were popped become empty (no collision) - Also ensure that after popping the connected bubbles, the bubbles are not just removed from the screen but the game engine itself. So if we shoot a bubble at these now empty locations it should behave like an empty cell
			- Test if a group is removed, they must be directly connected. Should not remove indirect neighbours that are the same color as the connected group.
			(E.g. [Group with color A - Direct neighbour of different color B - Indirect neighbour of same color A] the indirect neighbour should not get popped)
		- Test dropping of floating bubbles
			- The dropping animation should be the same speed for all floating bubbles (regardless of positioning should fall at same speed)
			- Test no floating groups (nothing should drop in this case)
			- Test floating groups exist
				1. Test floating group distance
					- Test floating group of bubbles at distance of 1 cell away from some group connected to the top of the grid (the floating group should be removed)
					- Test floating group at distance of 2 cells away from some group connected to the top of the grid (the floating group should be removed)
					- Test the above for >= 3 cells away
				2. Test floating group size
					- Floating group size 1
					- Floating group size 2
					- Floating group size >= 3
				3. Floating group colors - should not affect whether they are dropped or not
					- All same color
					- Have different colors
				4. Number of isolated floating groups - all should be removed regardless
					- 1 floating group
					- 2 floating groups
					- number of floating groups >= 3
				5. Test floating bubbles that were connected to any topmost section bubbles that will be popped as a result of being connected bubbles (as my algorithm involves enqueueing top section bubbles)
				6. Test floating bubbles that were connected to any non-top most section bubbles that will be popped as a result of being connected bubbles
				7. Some combination of the above factors
		- Test snapping of bubble
			1. Test snapping of bubble upon collision with another (stationary) bubble
				- Snaps to the closest empty neighbour cell of that stationary bubble
			2. Test snapping of bubble upon collision with top edge
				- Snaps to the closesst empty top section cell
	

### Problem 9: The Bells & Whistles

1. **Added a trajectory animation and path to the cannon.** While the user is taking aim, the path of the bubble will be projected so that the user can fine tune his aim. Modification made: Need to use the physics engine to manually step through for the special trajectory bubble and after each step add its position to an array of points. Then when the bubble stops, or after a limit is reached on the number of points, draw a bezier path connecting those points.
2. **Added bubble bursting animation when bubbles are popped.** For this, I realised my classes that did the animation previously were a bit restrictive as I only took into account animations using `UIView.animateWithDuration(...)`. The bubble bursting animation required the use of a UIImageView's animationImages instead. Previously, my `Renderer` was doing the animations, and I had an `AnimationHelper` that generates the *animation code block* that is used in the `UIView.animateWithDuration(...)` method. As you can see it only takes into account a certain type of animation using the UIView but cannot use the `UIImageView`'s animationImages property. So I had to reorganize my animation code and create a `BubbleGameAnimator` class for `BubbleGameLogic` to know about and call whenever an animation needs to be done due to logic stuff. `BubbleGameAnimator` will then execute the appropriate animation accordingly. `BubbleGameAnimator` is able to execute both types of animations that I mentioned before. I feel that this change is good as these animations are a bit *game-specific* for the `Renderer` to know about so having a `BubbleGameAnimator` do these instead of a `Renderer` doing these feels abit more cohesive, and also the `Renderer` more reusable.
3. **Added an advanced hint system to inform user of best case position for the bubble to be to maximize bubbles removed.** This is an improved version of the previous system, that actually does simulation of the outcomes for each candidate positions of the basic system. It then reveals the best position for the current bubble to be in. A consideration is that there is a *thinking time* incurred to decide which is the best position due to running simulations. In order to prevent lag to the game, I used async calls for the hints so that the UI will never appear laggy. Although, this would mean that there might be a little delay in the computation of the hint.
4. **Added game score.** The score is shown at the bottom of the screen, below all the bubbles. Each bubble removed will contribute to the score with a base score, and the score will be boosted based on the current streak of the player and the combo of the player.
5. **Added retry and back button in game view.** *Retry button* allows the player to restart the level and attempt the level again from the start. *Back button* allows the player to go back to the previous screen he came from (e.g. he started from Level Designer, so go back to Level Designer).
6. **Added game end condition based on time limit.**
	* Player has unlimited shots to fire, but can only play for a certain time limit for the level. After the time limit expires, the game will end, and depending on whether there are still bubbles in the grid, the player wins or loses. If the bubble grid becomes empty at any point in the game, the player will win.
7. **Added game statistics.** The game will track statistics about the user. These include the best combo the player achieved, the lucky color for the player (the colored bubble which led to the best combo), the best chain count achieved, the best removal streak and the accuracy of the player.
8. **Added end game screen.** The end game screen displays the game outcome and the game score. The retry and back button also move to the center of the screen for easy access. The end game screen also shows some simple statistics for the player for that level. .
9. **Added effects for lightning, bomb and star bubble.** For lightning, a lightning bolt will be flashed across the screen along the section of the grid where the lightning bubble was. For bomb bubble, an explosion effect will be generated around the location of the bomb bubble. For the star bubble, a glowing star will be generated at the locations of all colored bubbles to be removed due to the star.
10. **Added validation check for level designer.** User will not be allowed to start or save the level unless it is valid.
11. **Added button to swap the current and next bubbles.** Player can swap current bubble and next bubble, allowing the player to have more options to shoot if he cannot find a satisfactory location to fire with the current bubble. Player cannot swap while swap is in progress, have to wait until the previous swap completes first.
12. **Added improved level select menu.** The level select cards show a preview of the bubble grid, and also the highscore of the player for that particular level.
13. **Added highscore.** Added highscore tracking for each level played.


### Problem 10: Final Reflection

My original design for the MVC architecture was quite good as the model, view and controllers were clearly separated into distinct groups, so they were all very cohesive and had little coupling among each other. The communication between them is also ideal, following the MVC's recommended pattern.

My original game engine design was not very good as I did not really understand what the best way of implementing the game engine was, unlike the previous one where we were just supposed to follow MVC architecture. 

In order to improve the design of 