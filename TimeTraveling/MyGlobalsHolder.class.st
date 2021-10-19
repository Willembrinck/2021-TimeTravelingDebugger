Class {
	#name : #MyGlobalsHolder,
	#superclass : #Object,
	#classVars : [
		'aBoolean'
	],
	#category : #TimeTraveling
}

{ #category : #'as yet unclassified' }
MyGlobalsHolder class >> aBoolean [

	^ aBoolean
]

{ #category : #'as yet unclassified' }
MyGlobalsHolder class >> aBoolean: anObject [

	aBoolean := anObject
]

{ #category : #initialization }
MyGlobalsHolder class >> initialize [

	aBoolean := false
]
