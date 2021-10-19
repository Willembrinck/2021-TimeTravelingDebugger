Class {
	#name : #TTD,
	#superclass : #Object,
	#instVars : [
		'rootContext',
		'stDebugger',
		'instructionCounter',
		'changes',
		'stateReader',
		'preventUIUpdate'
	],
	#category : #TimeTraveling
}

{ #category : #'instance creation' }
TTD class >> newWithRootContext: aContext [

	^ self new
		  rootContext: aContext;
		  stDebugger: aContext findOwningProcess findOwningStDebugger;
		  yourself
]

{ #category : #initialization }
TTD >> initialize [

	instructionCounter := 1.
	changes := OrderedCollection new.
	stateReader := ExecutionStateReader newForTimeTravelingDebugger: self.
	preventUIUpdate := false
]

{ #category : #'as yet unclassified' }
TTD >> preStep [

	(stateReader isMessageSend and: [ 
		 stateReader isAboutToSendWritingPrimitive ])
		ifTrue: [ 
			| object originalValue |
			object := stateReader messageReceiver.
			originalValue := stateReader messageReceiver shallowCopy.
			changes add: [ object copySameFrom: originalValue ] ]
		ifFalse: [ 
			stateReader isAssignmentOfNonLocalVariable ifTrue: [ 
				| variable object variableName originalVariableValue |
				variable := stateReader currentAstNode variable variable.
				object := stateReader currentContext receiver.
				variableName := variable name.
				originalVariableValue := stateReader
					                         currentValueOfAssignmentVariable.
				variable isClassVariable ifTrue: [ 
					changes add: [ 
						object
							writeClassVariableNamed: variableName
							value: originalVariableValue ] ].
				variable isInstanceVariable ifTrue: [ 
					changes add: [ 
						object writeSlotNamed: variableName value: originalVariableValue ] ] ] ]
]

{ #category : #starting }
TTD >> restart [

	"Restart the context through the DebugSession API"

	changes reverseDo: [ :each | "perform all undo routines" each value ].
	stDebugger session restart: rootContext.
	instructionCounter := 1.
	changes removeAll.
	stateReader := ExecutionStateReader newForTimeTravelingDebugger: self
]

{ #category : #accessing }
TTD >> rootContext [

	^ rootContext
]

{ #category : #accessing }
TTD >> rootContext: anObject [

	rootContext := anObject
]

{ #category : #accessing }
TTD >> stDebugger [

	^ stDebugger
]

{ #category : #accessing }
TTD >> stDebugger: anObject [

	stDebugger := anObject
]

{ #category : #'as yet unclassified' }
TTD >> stepBackward [

	| targetInstructionCounter currentContext |
	targetInstructionCounter := 1 max: instructionCounter - 1.

	stDebugger removeSessionHolderSubscriptions. "prevent UI update"

	self restart.
	[ instructionCounter < targetInstructionCounter ] whileTrue: [ 
		currentContext := self stepForward ].

	stDebugger setSessionHolderSubscriptions. "resume UI updatess"
	self updateUI: currentContext
]

{ #category : #'as yet unclassified' }
TTD >> stepForward [

	| newContext |
	"Disabling stepping optimization, so the debugger stop not only in interesting bytecodes."
	stDebugger session interruptedContext stepIntoQuickMethod: true.

	self preStep.
	newContext := stDebugger session interruptedProcess step.
	instructionCounter := instructionCounter + 1.

	"updating the UI. This call is necessary for stDebugger in case a new context is activated (or the current one is returned)"
	self updateUI: newContext.
	^ newContext
]

{ #category : #'as yet unclassified' }
TTD >> updateUI: aContext [

	preventUIUpdate ifFalse: [ 
		self stDebugger session updateContextTo: aContext.
		self stDebugger debuggerActionModel updateTopContext.
		self stDebugger updateStep. ]
]
