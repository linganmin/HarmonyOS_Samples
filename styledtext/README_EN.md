# Rich Text Display

## Overview

This sample demonstrates the display effects of rich text content across four scenarios, including highlighted hyperlink text, custom emoticons, icon-and-text combination, and custom image-text elements.
## Effect

<img src="./screenshots/device/result_en.gif" style="width:320px">

## How to Use

1. Tap the corresponding button to navigate to different pages.
2. Tap a topic, @user, or video to open its respective details page.

## Project Directory

   ```  
   ├──entry/src/main/ets
   │  ├──common 
   │  │  └──HandleData.ets           // Common method    
   │  ├──components 
   │  │  └──MyDrawCustomSpan.ets     // Custom component    
   │  ├──mock 
   │  │  └──MockData.ets             // Mock data         
   │  ├──model                                
   │  │  └──MyCustomSpan.ets         //  Data type definition
   │  └──pages                       // View layer
   │     ├──CustomizeEmoji.ets       // Custom emoticon page
   │     ├──Home.ets                 // Home page
   │     ├──ImageText.ets            // Custom image-text element page 
   │     ├──TitleDetail.ets          // Redirection page - #topic 
   │     ├──TitleLink.ets            // Highlighted hyperlink text page 
   │     ├──UserDetails.ets          // Redirection page - @user            
   │     └──VideoLink.ets            // Icon-and-text combination page 
   └──entry/src/main/resources       // Application resources                                                     
   ```

## How to Implement

The TextAndSpanComponent distinguishes between different types of text using custom Span objects. Within the Text component, the TextAndSpanComponent iterates over the Span object array, checks the character length, and generates Span components with unique styles and functionalities based on each Span's type.
1. Use TextAndSpanComponent to iterate over MyCustomSpan objects in the array and generate properties for distinct styles and events based on span types.
2. Set linkClickCallback to perform operations based on the span type, for example, redirecting to a details page or video page.

## Required Permissions
N/A

## Dependencies
N/A

## Constraints
1. This sample is only supported on Huawei phones running standard systems.
2. The HarmonyOS version must be HarmonyOS 5.1.0 Release or later.
3. The DevEco Studio version must be DevEco Studio 5.1.0 Release or later.
4. The HarmonyOS SDK version must be HarmonyOS 5.1.0 Release SDK or later.