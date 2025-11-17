cd /tf/avm/templates/landingzone/configuration/1-landingzones/scripts

sudo chmod -R -f 777 /tf/avm/templates/landingzone/configuration/1-landingzones/scripts

python3 csv_to_yaml.py 

./replace.sh

