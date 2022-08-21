# **TruckJob - Work as a truck driver**
![truckjob](https://user-images.githubusercontent.com/79053058/185757903-e0aabb8e-a8e7-4be8-93d6-5f2d6ae5d3fb.png)

## :bookmark_tabs: **Description** 
This FiveM resource enables the player to work as a truck driver and deliver cargo to locations around the map.

If you are using [ND_Framework](https://forum.cfx.re/t/updated-nd-framework-addons/4792200) by **Andy7666**, you can reward the player for completing the job with money, or penalise them for cancelling the job. If you want it to be standalone, then simply set **UseND** to **false** in the config.lua. You can also simply convert the script to make it work with any framework you want.

This job consists of 3 parts:
1. Start your shift at the truck depot, go pick up the trailer at a location.
2. Pick up the trailer and drive to the destination.
3. Detach the trailer and drive back to the depot to get paid.  

The player can decide to cancel the job at any moment. If that happens, they will have to bring back the truck to the depot where they will pay a penalty.

## :bulb: **Features** 
- Customise the minimum, maximum amd the penalty money amount (if using ND)
- Set a custom truck model for the job
- Set the possible locations for the trailers to spawn
- Set the possible destinations where you have to drive the trailer to
- Add custom trailers for the job  

... and much more!  
Check the config.lua for more information.

## :eyes: **Preview** 
[YouTube](https://youtu.be/TQ-zqjlY9GU)

## 📈 Resmon
| Context | CPU |
| ------------- | ------------- |
| Idle  | 0.01 ms  |
| Peak  | 0.02 ms  |

## 📥 Installation
- Rename the folder from `TruckJob-main` to `TruckJob`
- Drag the folder to your server resource folder
- Add `start TruckJob` or `ensure TruckJob` to your server.cfg 

## :white_check_mark: **Changelog**
> **v1.0**
> - Initial Release 
