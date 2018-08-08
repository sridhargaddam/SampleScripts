# This is quickstart and infrared proof

source ~/stackrc
touch nodesrc
for i in $(nova list | awk 'NR>=4 {print $4 $12}')
do
  node=$(echo $i | awk -F 'ctlplane=' '{print $1}')
  ip=$(echo $i | awk -F 'ctlplane=' '{print $2}')
  echo $node $ip
  echo "alias $node='ssh heat-admin@$ip'" >> nodesrc
done
source nodesrc
