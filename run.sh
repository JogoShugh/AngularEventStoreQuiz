export PATH=$(pwd)/node_modules/.bin:$PATH
/c/CQRS/eventstore-net-2.0.1/EventStore.SingleNode.exe --db /c/CQRS/eventstore-net-2.0.1/db --log /c/CQRS/eventstore-net-2.0.1/logs --run-projections=all &
nws &