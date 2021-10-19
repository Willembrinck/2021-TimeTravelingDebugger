Class {
	#name : #MyExecutionsLib,
	#superclass : #Object,
	#category : #TimeTraveling
}

{ #category : #'as yet unclassified' }
MyExecutionsLib class >> fullDeterministic [

	| a |
	a := 1.
	a := a + 1.
	^ a
]
