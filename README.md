# trumpR

{DISCLAIMER: This project is no longer functioning as there appear to have been changes to the Twitter API which is causing the script to fail. Timeline for redeployment is unknown. Thanks for your patience.}

I initiated this project after learning the basics of R on DataCamp (of whose services I am an avid fan). This represents my first foray into using R for actual data acquisition and visualization. A brief description of the steps I took to complete this project are below. 

This project utilizes data from the Twitter REST API, which I accessed through an application I registered directly with Twitter. Although an R package exists (twitteR) that would have likely made my analysis a bit more straightforward, I felt working through some of the issues outside of the package would provide a better learning experience. 

The R script within this repo is fairly simple and likely does not follow certain coding best practices, however, it represents my best efforts to gather, format and display interesting data in a way that I was previously unfamiliar with. Please note that in its current form, the script will likely take more than 3 hours to fully execute.

In sum, the script uses the httr package to submit GET requests to the Twitter API for a random subset of 2016 US presidential candidate Donald Trump's Twitter followers and plots their locations on a world map.
