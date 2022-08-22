# **TruckJob - Work as a truck driver**
![truckjob](https://user-images.githubusercontent.com/79053058/185757903-e0aabb8e-a8e7-4be8-93d6-5f2d6ae5d3fb.png)

## :bookmark_tabs: **Description** 
This FiveM resource enables the player to work as a truck driver and deliver cargo to locations around the map.

If you are using [ND_Framework](https://forum.cfx.re/t/updated-nd-framework-addons/4792200) by **Andy7666**, you can reward the player for completing the job with money. If you want it to be standalone, then simply set **UseND** to **false** in the config.lua. You can also simply convert the script to make it work with any framework you want.

This job consists of 3 parts:
1. Start your shift at the truck depot, go pick up the trailer at a location.
2. Pick up the trailer and drive to the destination.
3. Detach the trailer and choose to get another job or return to the depot.  

The player will be paid based on how many trailers have been delivered.

## :bulb: **Features** 
- Customise the amount of money you get when completing a task (if using ND)
- Set a custom truck model for the job
- Set the possible locations for the trailers to spawn
- Set the possible destinations where you have to drive the trailer to
- Add custom trailers 

... and much more!  
Check the config.lua for more information.

## :eyes: **Preview** 
[YouTube](https://youtu.be/TQ-zqjlY9GU)

## :bar_chart: Resmon
| Context | CPU |
| ------------- | ------------- |
| Idle  | 0.01 ms  |
| Peak  | 0.02 ms  |

## :inbox_tray: Installation
- Rename the folder from `TruckJob-main` to `TruckJob`
- Drag the folder to your server resource folder
- Add `start TruckJob` or `ensure TruckJob` to your server.cfg 

## :white_check_mark: **Changelog**
> **v1.2**
> - Added validations for server events to avoid exploits
> - Players now get paid based on how many trailers they deliver

> **v1.1**
> - Revamped and optimized code
> - Added possibility to accept a new job when a delivery has been made

> **v1.0**
> - Initial Release 

## :heart: **Support me**
Please consider leaving a like or a simple comment if you enjoyed this release, to show support and allowing me to keep making free high-quality resources.  

You can also check out my other releases:
- [HealingPads](https://forum.cfx.re/t/free-healingpads-heal-at-hospitals/4888341)
- [ShotSpotter](https://forum.cfx.re/t/free-shotspotter-gunshot-detection-system/3599253/1)
- [CarLock](https://forum.cfx.re/t/free-carlock-animation-sound/3768972/1)
