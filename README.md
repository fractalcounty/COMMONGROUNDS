## Getting started (for Jason :-3)

1. Download [Godot 4.2.1](https://godotengine.org/download/windows/) and put it somewhere accessible
2. Install [Github Desktop](https://desktop.github.com/) and then [clone the repository](x-github-client://openRepo/https://github.com/fractalcounty/ChasersWorld) (take note of the local path)
3. Open Godot_v4.2.1.exe and import the previously mentioned path, then open the project
4. Install [Visual Studio Code](https://code.visualstudio.com/) (VSC) as well as the [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) VSC plugin
5. Back in Godot, go to 'Editor' > 'Editor Settings...' in the top left toolbar
	-  **External**: Set 'Use External Editor' to 'On' and 'Exec Path' to your VSC install location: ![](https://github.com/fractalcounty/ChasersWorld/blob/main/docs/external_editor.png)
	- **Completion:** Set 'Add Type Hints' to 'On': ![](https://github.com/fractalcounty/ChasersWorld/blob/main/docs/type-hints.png)

6. *Optional*: Install [Obsidian](https://obsidian.md/) and add your cloned repository as a Vault. Obsidian is a **REALLY GOOD** note-taking and documentation app that I already have setup to sync with the repository
## Resources and recommendations (also for Jason)
- **Push every single time you make changes OR ELSE**. Although Godot is pretty reliable, random data loss **WILL** happen a lot, and you **WILL** have to revert to your last Github commit **VERY FREQUENTLY**.... Think of it like saving your progress in a game that has a 1% chance of erasing your progress at any given moment. Think of it like Flowey is in your computer ![](https://github.com/fractalcounty/ChasersWorld/blob/main/docs/warning.png)

- [The Godot documentation](https://docs.godotengine.org/en/stable/index.html) is **AMAZING** and should be the #1 resource you'll use
- **Don't blindly follow tutorials** without ensuring that they were made for *at least* Godot 4.0 or higher. Godot 3.5+ tutorials *might* be of some use but should generally be avoided.
	- Most Godot tutorials also suck, so just a fair warning. ChatGPT is unironically better
	- [GDQuest](https://www.gdquest.com/tutorial/) is the exception but a lot of them are either for 3.x or are [paywalled but very worth it](https://school.gdquest.com/products/godot-4-early-access). They also have a [YouTube channel too](https://www.youtube.com/@Gdquest) you should check out
- [ChatGPT](https://chat.openai.com/) is good for debugging, problem solving, and 'rubber ducking' with **only if you use GPT-4 via ChatGPT Pro**. However, it's still not amazing at reliably generating GDScript 2.0 syntax since it was trained on Godot 3.x. But use it anyways! Feel free to use my ChatGPT Plus account:
		**Username:** pondethan@icloud.com
		**Password:** rU6ANE_bgL8Muwx-dsaW
		*Note, if you use this: make sure you select 'GPT-4' from the dropdown every time you start a new chat, or else it will use GPT-3.5 which is like GPT-4s retarded useless cousin*
- Try to maintain the best practices to reduce bugs and help me understand what you're adding
	- Familiarize yourself with the [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) to keep your scripts beautiful
	- Use **static typing** at all times to keep your scripts fast & bug-free. If you aren't sure what static typing is or how to use it in GDScript, see the [static typing doc page here](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html)
	- If you make commits to the repository, write descriptions so I know wtf is going on
	- Try to stick to decent project structure practices. Here's a guide I made outlining it:
	![](https://github.com/fractalcounty/ChasersWorld/blob/main/docs/Frame%201%20(1).png)
