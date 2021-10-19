Extension { #name : #Process }

{ #category : #'*TimeTraveling' }
Process >> findOwningStDebugger [

	StDebugger allInstancesDo: [ :each | 
		each session interruptedProcess == self ifTrue: [ ^ each ] ].
	^ nil
]
