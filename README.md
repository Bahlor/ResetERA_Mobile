# ResetERA_Mobile
A very basic wrapper ios app for ResetERA discussion board to allow customized css, stylish themes and some additional functionalities for users with ios devices.

![Image of the app with dark theme](https://i.imgur.com/EqlIxUr.png)
[Video of the app in action](http://sendvid.com/0ibfnbzq)

## Why?
This project was quite rushed and was actually never planned to be what it is now, so please don't be shocked when looking at the highly unoptimized and unorganized project. I just wanted to have a small mobile app version with some additions for myself so I created this, but I thought it might be useful for other users (especially for those that want dark theme support on ios mobile devices).

## How?
If you're familiar with development on apple devices you will have most likely have the knowledge to deploy the app on your device. If you have no idea how to do it and also don't want to get an apple developer account, I found the following tutorial on how deploy apps on your own device without a developer license: http://www.wastedpotential.com/running-xcode-projects-on-a-device-without-a-developer-account-in-xcode-7/

If you want to add some custom css that overwrites all other directives, you can just add it to **additionals.css** found in the root project folder. This stylesheet will always be injected and at the last position.

## Bugs?
I'm sure there are some. I did not test a lot and there are no unit tests included. As I use the app on a daily basis, I find it quite functional

## Todos?
 - Sorting of injection order an themes manager
 - ajax reload javascript injection
 - css replacement of author attributes with username
