Extension { #name : #Context }

{ #category : #'*TimeTraveling' }
Context >> findOwningProcess [

	Process allInstancesDo: [ :each | 
		each suspendedContext == self ifTrue: [ ^ each ] ].
	^ nil
]
