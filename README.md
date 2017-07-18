In this project,HTTP log data was read then machine learning was applied to predict segment duration of the HTTP video segments using 3 predictors.
The most accurate model was then saved.
An API was developed.The restful API consumes 3 predictor values and outputs the predicted segment duration feature.
A python script was then created.The python script continuosly reads the log file and sends the values to the webservice so as to obtain real time predictions.
