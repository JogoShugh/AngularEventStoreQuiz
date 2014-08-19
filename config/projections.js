// QuestionAnswers:

fromStream('answers')
.whenAny(function(s, e) {
    linkTo('question-' + e.data.answer.questionId, e);
});

// QuestionAnswerCounts:

fromStream('answers').
    when({
        $init: function() {
            return { questions: {} };        
        },
        
        'Answer': function(s, e) {
            try 
            {
                var key = e.data.answer.questionId;
                if (key === undefined)
                    return;
                if (!s.questions[key]) {
                    s.questions[key] = { choices: {} };
                }
                var question = s.questions[key];
                if (question === undefined)
                    return;
                var choice = e.data.answer.choice;
                if (choice === undefined)
                    return;
                if (!question.choices[choice]) {
                    question.choices[choice] = 0;
                }
                question.choices[choice]++;
            } catch (ex) {                    
            }
        }
    });
// State:

/*

{"questions":{"1":{"choices":{"Consider using a functional style that passes your depdendencies via a closure":19,"Use a container that lets you use any kind of injection you like!":7,"You should use constructor injection always":27,"You should use constructor injection always!":1}},"2":{"choices":{"Magic-oriented programming":16,"Functional programming":7,"Aspect-oriented programming":28}},"3":{"choices":{"Because a class gets created at run-time that derives from your class to stand in its place":23,"Because you need to create a derived class in the code-behind next":4,"Language flaw":17}},"4":{"choices":{"Refactor parameters to object":25,"Extract interface":11,"Pull up method":9}},"5":{"choices":{"NCQRS":24,"C#QRS":8,"FCQRS":13}},"6":{"choices":{"When building a large-scale searchable index":2}},"7":{"choices":{"Use eventual consistency when users complain about latency":1,"Make systems that are able to recover from every failure":1}},"8":{"choices":{"When you make a sale in the sales system, remember the CAP theorem: we can only guarantee any two of the following properties: Consistency, Availability, and Partition tolerence at any one time. Therefore, we cannot guarantee that sales and billing will always be in sync":2}},"9":{"choices":{"Have William Shatner in Captain Kirk garb tell your user they are beaming the data into the servers. Use AJAX to poll the server for a response, and keep repeating Kirk in a loop until it's done, and then show the updated data":2}},"10":{"choices":{}}}}


*/