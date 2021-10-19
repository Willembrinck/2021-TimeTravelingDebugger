Class {
	#name : #TTD,
	#superclass : #Object,
	#instVars : [
		'rootContext',
		'stDebugger',
		'instructionCounter'
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

	instructionCounter := 1
]

{ #category : #starting }
TTD >> restart [

	"Restart the context through the DebugSession API"

	stDebugger session restart: rootContext.
	instructionCounter := 1
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

	| targetInstructionCounter |
	targetInstructionCounter := instructionCounter - 1.
	targetInstructionCounter < 1 ifTrue: [ targetInstructionCounter := 1 ].
	self restart.
	"Non optimized loop. note that it refreshes the UI in every step"
	[ instructionCounter < targetInstructionCounter ] whileTrue: [ 
		self stepForward ]
]

{ #category : #'as yet unclassified' }
TTD >> stepForward [

	| newContext |
	"Disabling stepping optimization, so the debugger stop not only in interesting bytecodes."
	stDebugger session interruptedContext stepIntoQuickMethod: true.


	newContext := stDebugger session interruptedProcess step.
	instructionCounter := instructionCounter + 1.

	"updating the UI. This call is necessary for stDebugger in case a new context is activated (or the current one is returned)"
	self updateUI: newContext
]

{ #category : #'as yet unclassified' }
TTD >> updateUI: aContext [

	self stDebugger session updateContextTo: aContext.
	self stDebugger updateStep
]
