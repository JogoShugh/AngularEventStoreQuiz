AngularEventStoreQuiz
=====================

Example of AngularJS + EventStore for a real-time quiz app

# Getting started

* You need to have EventStore running locally on the default port
* Create the projections from `config/projections.js` within EventStore
* Make sure you have Node.js installed
* Type `npm install`
* Type `. ./build.sh`
* Modify run.sh to point to your EventStore location
* Type `. ./run.sh`
* Navigate in your browser to `http://localhost:3030/index-step.html`