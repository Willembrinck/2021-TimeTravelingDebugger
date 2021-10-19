Class {
	#name : #ExecutionStateReader,
	#superclass : #Object,
	#instVars : [
		'timeTravelingDebugger'
	],
	#classVars : [
		'writingPrimitives'
	],
	#category : #TimeTraveling
}

{ #category : #initialization }
ExecutionStateReader class >> initialize [

	writingPrimitives := #( 39 61 64 69 74 144 145 166 211 549 615 616
	                        617 618 619 620 621 622 623 624 625 626 627
	                        628 629 645 646 647 648 649 650 651 652 653
	                        654 655 656 657 658 659 105 )
]

{ #category : #testing }
ExecutionStateReader class >> isWritingPrimitive: aNumber [

	^ writingPrimitives includes: aNumber
]

{ #category : #'instance creation' }
ExecutionStateReader class >> newForTimeTravelingDebugger: aTTD [

	^ self new
		  timeTravelingDebugger: aTTD;
		  yourself
]

{ #category : #testing }
ExecutionStateReader >> currentAstNode [

	| context |
	context := self currentContext.
	^ context method sourceNodeForPC: context pc
]

{ #category : #'accessing - context' }
ExecutionStateReader >> currentContext [

	^ timeTravelingDebugger stDebugger session interruptedContext
]

{ #category : #testing }
ExecutionStateReader >> currentValueOfAssignmentVariable [

	^ self currentAstNode variable variable readInContext:
		  self currentContext
]

{ #category : #testing }
ExecutionStateReader >> isAboutToSendWritingPrimitive [

	| methodAboutToExecute node |
	self isMessageSend ifFalse: [ ^ false ].
	node := self currentAstNode.
	node isMessage ifFalse: [ ^ false ].
	methodAboutToExecute := self methodAboutToBeExecuted.
	^ methodAboutToExecute notNil and: [ 
		  self class isWritingPrimitive: methodAboutToExecute primitive ]
]

{ #category : #testing }
ExecutionStateReader >> isAssignment [

	^ self currentAstNode isAssignment
]

{ #category : #testing }
ExecutionStateReader >> isAssignmentOfNonLocalVariable [

	^ self currentAstNode isAssignment and: [ 
		  self currentAstNode variable variable isLocalVariable not ]
]

{ #category : #testing }
ExecutionStateReader >> isMessageSend [

	^ self currentAstNode isMessage
]

{ #category : #testing }
ExecutionStateReader >> messageReceiver [

	"returns the message receiver of the message that is about to be sent"

	^ self currentAstNode isInlined
		  ifTrue: [ self currentContext top ]
		  ifFalse: [ 
			  | pointer |
			  pointer := self currentContext stackPtr
			             - self currentAstNode numArgs.
			  pointer <= 0 ifTrue: [ pointer := 1 ].
			  pointer > self currentContext size ifTrue: [ ^ nil ].
			  self currentContext at: pointer ]
]

{ #category : #testing }
ExecutionStateReader >> methodAboutToBeExecuted [

	"Returns the compiled method that will be executed by the current message send"

	| methodAboutToExecute node messageReceiver messageReceiverClass |
	node := self currentAstNode.
	messageReceiver := self messageReceiver.
	messageReceiverClass := messageReceiver class.
	node receiver isSuperVariable ifTrue: [ 
		messageReceiverClass := messageReceiverClass superclass ].
	methodAboutToExecute := messageReceiverClass lookupSelector:
		                        node selector.
	^ methodAboutToExecute
]

{ #category : #accessing }
ExecutionStateReader >> timeTravelingDebugger [

	^ timeTravelingDebugger
]

{ #category : #accessing }
ExecutionStateReader >> timeTravelingDebugger: anObject [

	timeTravelingDebugger := anObject
]

{ #category : #testing }
ExecutionStateReader >> valueAboutToBeAssigned [

	| context |
	context := self currentContext.
	^ context at: context basicSize
]
