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

{ #category : #'as yet unclassified' }
MyExecutionsLib class >> quasiDeterministic [

	"This function will return 0 or 3, alternating on every execution."

	"The TTD can restore the global value, ensuring determinism"

	| aNumber |
	aNumber := 0.
	MyGlobalsHolder aBoolean
		ifTrue: [ 
			MyGlobalsHolder aBoolean: false.
			aNumber := aNumber + 1.
			aNumber := aNumber + 1.
			aNumber := aNumber + 1 ]
		ifFalse: [ MyGlobalsHolder aBoolean: true ].
	^ aNumber "restarting the context(without the TTD) before returning will make the next execution to follow the other condition branch"
]
