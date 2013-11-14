(->
  quizApp = angular.module("quizApp", ["ui.bootstrap"])

  serverRoot = "http://localhost:2113"

  choice = (text, correct) ->
    correct = false if correct isnt true 
    text: text
    correct: correct
    selected: false

  quizApp.controller 'questionController', ($rootScope, $scope, questions) ->
    $scope.questions = questions
    $scope.questionTextPending = { value: '' }
    
    $scope.selectQuestion = (question) ->
      $scope.selectedQuestion = question
      $scope.questionTextPending.value = question.question
    
    $scope.selectQuestion $scope.questions[0]

    $scope.setChoiceCorrect = (question, choice) ->
      choice.correct = true
      for otherChoice in question.choices
        otherChoice.correct = false if otherChoice isnt choice
    
    $scope.getCorrectClass = (correct) ->
      if correct
        return 'btn-primary'
      else
        return ''

    $scope.getCorrectLabel = (correct) ->
      if correct 
        return 'correct'
      else 
        return 'incorrect'

    $scope.choiceRemove = (question, choice) ->
      if confirm('Are you sure you want to remove this choice?') 
        question.choices = question.choices.filter (otherChoice) -> otherChoice isnt choice

    $scope.choices = { newPending: [] }
    
    $scope.choiceNewAdd = ->
      choiceNew = choice('')
      $scope.choices.newPending.push choiceNew
    
    $scope.choiceNewSave = (choiceNew) ->
      $scope.selectedQuestion.choices.push choiceNew
      $scope.choices.newPending = $scope.choices.newPending.filter (otherChoice) -> otherChoice isnt choiceNew

    $scope.choiceNewDiscard = (choiceNew) ->
      if confirm('Are you sure you want to discard this new choice?')
        $scope.choices.newPending = $scope.choices.newPending.filter (otherChoice) -> otherChoice isnt choiceNew

    $scope.questionRemove = (question) ->
      if confirm('Are you sure you want to remove this new question?')
        $scope.questions = $scope.questions.filter (otherQuestion) -> otherQuestion isnt question

    questionId = 10
    $scope.questionNewAdd = ->
      questionNew =
        id: questionId++
        question: "Question?"
        choices: [
        ]
      $scope.questions.push questionNew
    
    $scope.questionTextApply = (question, text) ->
      question.question = text

    $scope.questionTextRevert = (question) ->
      $scope.questionTextPending.value = question.question

  quizApp.controller "quizController", ($rootScope, $scope, $http, Poller, questions) ->
    $scope.questions = questions
    getAnswerStreamUri = (lastUri, result) ->
      if not lastUri? or not result?
        return serverRoot + "/streams/answers/head/backward/20?embed=content"
      else
        return result.data.links[4].uri + "?embed=content"  if result.data.links[4].relation is "previous"
      lastUri
    updateAnswersArray = (result) ->
      $scope.answerStream.unshift(result.data.entries...)

    $scope.userName = value: "Guest" + (Math.floor(Math.random() * 100000))
    
    pollCurrentAnswers = Poller(2000, ->
      serverRoot + "/projection/QuestionAnswerCoutns2/state"
    )
    $scope.currentAnswers = pollCurrentAnswers.data
    
    $scope.answerStream = []
    pollAnswerStream = Poller(2000, getAnswerStreamUri, updateAnswersArray)
    
    $scope.quizVisible = true
    $scope.getCurrentAnswerCount = (questionId, choiceText) ->
      try
        count = $scope.currentAnswers.response.questions[questionId].choices[choiceText]
        return 0 if not count?
        return count
      catch ex
        return 0

    $scope.selectAnswer = (question, choice) ->
      for currentChoice in question.choices
        currentChoice.selected = false unless currentChoice is choice
      choice.selected = true

    $scope.sendAnswers = ->
      answers = []
      for question in $scope.questions
        answer =
          eventId: uuid.v4()
          eventType: "Answer"
          data:
            user: $scope.userName
            answer:
              questionId: question.id
              text: question.text
        for choice in question.choices
          if choice.selected
            answer.data.answer.choice = choice.text
            answer.data.answer.correct = choice.correct
        answers.push answer

      $http.post(serverRoot + "/streams/answers", answers).success ->
        $scope.successMessage = "Success!"
        $scope.quizVisible = false

  quizApp.factory "Poller", ($http, $timeout) ->
    createPoller = (interval, getUri, callback) ->
      data =
        response: {}   
      uri = getUri()
      poller = ->
        $http.get(uri).then (result) ->
          callback result  if callback
          data.response = result.data
          uri = getUri(uri, result)
          $timeout poller, interval
      poller()
      return data: data
    return createPoller

  questions = [
    id: 1
    question: "How should I inject a foo into a blah"
    choices: [
      choice("You should use constructor injection always"), 
      choice("Consider using a functional style that passes your depdendencies via a closure", true), 
      choice("Use a container that lets you use any kind of injection you like!")
    ]
  ,
    id: 2
    question: "What style of programming do you need to use when you have lots of attributes on top of a class or method, for things like [Logged] [Transactional] [Requires(Role.Admin)]"
    choices: [
      choice("Aspect-oriented programming", true),
      choice("Magic-oriented programming"),
      choice("Functional programming")
    ]
  ,
    id: 3
    question: "Why do you have to declare properties as virtual when you use tools that create dynamic proxies (like NHibernate)?"
    choices: [
      choice("Language flaw"),
      choice("Because a class gets created at run-time that derives from your class to stand in its place", true),
      choice("Because you need to create a derived class in the code-behind next")
    ]
  ,
    id: 4
    question: "When you have a method that takes several parameters, what's the name of the common refactoring that lets you generalize to a single parameter?"
    choices: [
      choice("Pull up method"),
      choice("Extract interface"),
      choice("Refactor parameters to object", true)
    ]
  ,
    id: 5
    question: "Which framework for CQRS in the .NET world went from a 'framework' to a 'reference application' (aka dead project)?"
    choices: [
      choice("FCQRS"),
      choice("C#QRS"),
      choice("NCQRS", true)
    ]
  ,
    id: 6
    question: "When should you prefer a pull model versus a push model"
    choices: [
      choice("When an inventory system needs to know about recent sales")
      choice("When building a large-scale searchable index", true)
      choice("When availability is more important than consistency")
    ]
  ,
    id: 7
    question: "What is something that developers should try to do more often?"
    choices: [
      choice("Make systems that are able to recover from every failure")
      choice("Use eventual consistency when users complain about latency")
      choice("Recognize when a technical problem should be seen as a business problem that might need a business solution, not a technical solution", true)      
    ]
  ,
    id: 8
    question: "What phrases may help business people feel comfortable with latency between parts of your system?"
    choices: [
      choice("When you make a sale in the sales system, your data will be eventually consistent in the billing system")
      choice("When you make a sale in the sales system, the computer may have to think a while before it shows up in billing. Call us if it takes too long.", true)
      choice("When you make a sale in the sales system, remember the CAP theorem: we can only guarantee any two of the following properties: Consistency, Availability, and Partition tolerence at any one time. Therefore, we cannot guarantee that sales and billing will always be in sync")      
    ]
  ,
    id: 9
    question: "When you do have eventual consistency between system components, what's an acceptable user experience?"
    choices: [
      choice("Redirect the user back to the screen to read the data they just updated immediately")
      choice("Have William Shatner in Captain Kirk garb tell your user they are beaming the data into the servers. Use AJAX to poll the server for a response, and keep repeating Kirk in a loop until it's done, and then show the updated data")
      choice("Lie to them. Tell them it's already done.", true)
    ]
  ]

  quizApp.constant('questions', questions)

)()  