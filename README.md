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
* Navigate in your browser to [http://localhost:3030/index-step.html](http://localhost:3030/index-step.html)

# Try it out

Here's what it looks like in action:

![Screenshot](https://s3.amazonaws.com/uploads.hipchat.com/12722/130235/EI7zzPCGgcf5cq0/upload.png)

* Start one browser and keep it on the **Quiz** tab.
* Start another and move to the **Results Monitor** tab, which observes the **QuestionAnswers** projection.
* Answer the question in the first browser, and notice the answer pop into place in real-time on the **Results Monitor** tab.
* Continue taking the quiz, one question at a time.
* If you open a third browser and check the **Show current answer counts**, you'll see the counts update in real-time as other people select a given answer choice. This observes the **QuestionAnswerCounts** projection.

# Next steps

Oh I don't know...reimplement with MeteorJS :-D
