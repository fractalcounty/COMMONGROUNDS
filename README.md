### Getting started (for Jason :-3)

1. Download [Godot 4.2.1](https://godotengine.org/download/windows/) and put it somewhere accessible
2. Install [Github Desktop](https://desktop.github.com/) and then [clone the repository](x-github-client://openRepo/https://github.com/fractalcounty/ChasersWorld) (take note of the local path)
3. Open Godot_v4.2.1.exe and import the previously mentioned path, then open the project
4. Install [Visual Studio Code](https://code.visualstudio.com/) (VSC) as well as the [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) VSC plugin
5. Back in Godot, go to 'Editor' > 'Editor Settings...' in the top left toolbar
	-  **External**: Set 'Use External Editor' to 'On' and 'Exec Path' to your VSC install location: ![[external_editor.png]]
	- **Completion:** Set 'Add Type Hints' to 'On':
	![[type-hints.png]]
6. Then you should be good to go!

### Resources and recommendations (also for Jason)
- [The Godot documentation](https://docs.godotengine.org/en/stable/index.html) is **AMAZING** and are the #1 resource you'll use
- Don't blindly follow tutorials without ensuring that they were made for *at least* Godot 4.0 or higher. Godot 3.5+ tutorials *might* be of some use but should generally be avoided.
- [ChatGPT](https://chat.openai.com/) is good for debugging, problem solving, and 'rubber ducking' with. However, it's pretty outdated and isn't the best at reliably generating GDScript 2.0 syntax. But use it anyways! It's a good tool. Feel free to use my account:
	**Username:** pondethan@icloud.com
	**Password:** rU6ANE_bgL8Muwx-dsaW
- Try to maintain the best practices to reduce bugs and help me understand what you're adding
	- Familiarize yourself with the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) to keep your scripts beautiful
	- Use **static typing** at all times to keep your scripts fast & bug-free. If you aren't sure what static typing is or how to use it in GDScript, see the [static typing doc page here](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
	- If you make commits to the repository, write descriptions so I know wtf is going on
	- Try to stick to decent project structure practices. Here's a guide I made outlining it:
	![[Frame 1 (1).png]]