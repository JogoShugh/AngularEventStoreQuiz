var quizApp = angular.module('quizApp', ['ui.bootstrap']);
var serverRoot = 'http://localhost:2113';

quizApp.controller("quizController", function($rootScope, $scope, $dialog, $http, Poller) {
  $scope.userName = { value: 'Guest' + (Math.floor(Math.random() * 100000)) };
  
  pollCurrentAnswers = Poller(2000, function() { return serverRoot + '/projection/QuestionAnswerCoutns2/state'; });
  $scope.currentAnswers = pollCurrentAnswers.data;

  $scope.answerStream = [];
  function getAnswerStreamUri(lastUri, result) {    
    if (!lastUri || !result) {
      return serverRoot + '/streams/answers/head/backward/20?embed=content';
    } else {
      if (result.data.links[4].relation == 'previous') {
        return result.data.links[4].uri + '?embed=content';
      }      
    }
    return lastUri;
  }
  function updateAnswersArray(result) {
    console.log('The result:');
    console.log(result.data);
    for (var i = result.data.entries.length-1; i > -1; i--) {
      $scope.answerStream.unshift(result.data.entries[i]);
    }
  }  
  pollAnswerStream = Poller(2000, getAnswerStreamUri, updateAnswersArray);

  $scope.quizVisible = true;
  $scope.getCurrentAnswerCount = function(questionId, choiceText) {
    try {
      var count = $scope.currentAnswers.response.questions[questionId].choices[choiceText];
      if (count === null || count === undefined) {
        return 0;
      }
      return count;
    } catch (ex) {
      return 0;
    }
  }

  $scope.selectAnswer = function(question, choice) {
    for (var i = 0; i < question.choices.length; i++) {
      var currentChoice = question.choices[i];
      if (currentChoice != choice) {
        currentChoice.selected = false;
      }
    }
    choice.selected = true;
  }
  
  $scope.sendAnswers = function() {
    var id = uuid.v4();
    var answers = [];
    for (var i = 0; i < $scope.questions.length; i++) {
      var question = $scope.questions[i];
      var answer = {
        eventId: uuid.v4(),
        eventType: 'Answer',
        data: {
          user: $scope.userName,
          answer: {
            questionId: question.id,
            text: question.text,
          }
        }
      };
      for (var j = 0; j < question.choices.length; j++) {
        var choice = question.choices[j];
        if (choice.selected) {
          answer.data.answer.choice = choice.text;
          answer.data.answer.correct = choice.correct;
        }
      }
      answers.push(answer);
    }
   
    $http.post(serverRoot + '/streams/answers', answers).success(function() {
      $scope.successMessage = 'Success!';
      $scope.quizVisible = false;
    });
  };

  function choice(text, correct) {
    if (correct !== true && correct !== false) {
      correct = false;
    }
    return {text:text, correct:correct, selected:false};
  }  

  $scope.questions = [
    {
      id: 1,
      question: "How should I inject a foo into a blah",
      choices: [
        choice('You should use constructor injection always'),
        choice('Consider using a functional style that passes your depdendencies via a closure', true),
        choice('Use a container that lets you use any kind of injection you like!')
      ]
    },
    {
      id: 2,
      question: "What style of programming do you need to use when you have lots of attributes on top of a class or method, for things like [Logged] [Transactional] [Requires(Role.Admin)]",
      choices: [
        choice('Aspect-oriented programming',true),
        choice('Magic-oriented programming'),
        choice('Functional programming')
      ]
    },
    {
      id: 3,
      question: "Why do you have to declare properties as virtual when you use tools that create dynamic proxies (like NHibernate)?",
      choices: [
        choice('Language flaw'),
        choice('Because a class gets created at run-time that derives from your class to stand in its place',true),
        choice('Because you need to create a derived class in the code-behind next')
      ]
    },
    {
      id: 4,
      question: "When you have a method that takes several parameters, what's the name of the common refactoring that lets you generalize to a single parameter?",
      choices: [
        choice('Pull up method'),
        choice('Extract interface'),
        choice('Refactor parameters to object', true)
      ]
    },
    {
      id: 5,
      question: "Which framework for CQRS in the .NET world went from a 'framework' to a 'reference application' (aka dead project)?",
      choices: [
        choice('FCQRS'),
        choice('C#QRS'),
        choice('NCQRS',true)
      ]
    }
  ];
});

quizApp.factory('Poller', function($http, $timeout) {
  var createPoller = function(interval, getUri, callback) {
    var data = { response: {}, calls: 0 };
    var uri = getUri();
    var poller = function() {
      console.log('using uri:');
      console.log(uri);
      $http.get(uri).then(function(result) {
        if (callback) { callback(result); }
        data.response = result.data;        
        uri = getUri(uri, result);
        $timeout(poller, interval);
      });
      
    };
    poller();
    
    return {
      data: data
    };
  };
  return createPoller;
});