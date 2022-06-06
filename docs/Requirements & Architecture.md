# Requirements

This project will create the artifacts necessary to extract data from the Harvest site API. 
It should do a whole extraction of data given an user. Consider the use of a date attribute to filter
the data. Apart from that possible filter attribute, no other filters will need to be used.

## Architecture
 
 This will be a typical small BI project, where all the phases are kept and done by the main tool PowerBI.
 The main extraction tool will be API calls to the data's sources.

 A typical BI/ data oriented project will have some clear phases and parts with different responsibilities. Lets show these phases/part on the below list.

 1. Extract and load phase
 This phase will extract the raw data from the Harvest's APIs and will store it directly on PowerBI

 2. Transformation and modelization
 This phase will clean and transform the raw data into a cleaned and coherent BI model.

 3. Build dashboards with KPIs
 This phase will be done by David.

## Recomendations
