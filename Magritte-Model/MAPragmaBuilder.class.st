"
I dynamically build container descriptions from instance-side methods decorated pragmas. The pragmas used are:
# ==#magritteContainer== to identify the method generating the container instance.
# ==#magritteDescription== for unary methods returning valid Magritte descriptions which are added to the container.
# ==#magritteDescription:== for single parameter methods returning Magritte description extensions, where the pragma parameter defines the related Magritte description method. The extension method will be called after the related method to refine the description definition.
"
Class {
	#name : #MAPragmaBuilder,
	#superclass : #MABasicObject,
	#category : #'Magritte-Model-Utility'
}

{ #category : #constants }
MAPragmaBuilder class >> containerPragma [ 
	^ #magritteContainer
]

{ #category : #'instance creation' }
MAPragmaBuilder class >> for: anObject [
	^ self new for: anObject
]

{ #category : #constants }
MAPragmaBuilder class >> magritteDescriptionClassPragma [ 
	^ #magritteDescriptionClass
]

{ #category : #constants }
MAPragmaBuilder class >> magritteDescriptionExtensionPragma [ 
	^ #magritteDescription:
]

{ #category : #constants }
MAPragmaBuilder class >> magritteDescriptionPragma [ 
	^ #magritteDescription
]

{ #category : #constants }
MAPragmaBuilder class >> magritteSelectors [
	^ Array with: self containerPragma with: self magritteDescriptionExtensionPragma with: self magritteDescriptionPragma
]

{ #category : #private }
MAPragmaBuilder >> build: anObject cache: cache [
	| container |
	container := cache at: anObject put: (self buildContainer: anObject).
	
	^ container
		addAll: (self buildDescriptions: anObject);
		yourself.

]

{ #category : #private }
MAPragmaBuilder >> buildContainer: anObject [
	| containerPragmas containerPragma containerSelector extensionSelectors container |
	
	containerPragmas := Pragma 
		allNamed: self class containerPragma 
		from: (anObject desc) class to: Object.
		"Ovde mozda ne moram da ugnjezdujem ovo desc?!"
		
	containerPragma := containerPragmas detect: [ :each | each method numArgs = 0 ].
	containerSelector := containerPragma method selector.

	extensionSelectors := (containerPragmas 
		select: [ :each | each method numArgs = 1 ]) 
		collect: [ :each | each method selector ]. 

	MADynamicDescribedObject use: anObject during: [	
		container := anObject perform: containerSelector.
		extensionSelectors do: [ :each | 
			anObject perform: each with: container ] ].

	^ container
]

{ #category : #private }
MAPragmaBuilder >> buildDescriptions: anObject [
	| descriptionExtensions descriptionSelectors descriptionC |
	
	descriptionC := self descriptionClass: anObject.
	descriptionSelectors := self uniqueDescriptionSelectors: descriptionC.
	descriptionExtensions := self descriptionExtensions: descriptionC.

	^ (descriptionSelectors 
		collect:  [ :each |
			| description |
			"description := anObject desc perform: each."
			description := descriptionC perform: each.
			
			description notNil ifTrue: [
				descriptionExtensions at: each ifPresent: [ :extensions | 
					extensions do: [ :extensionSelector | 
						description := descriptionC perform: extensionSelector with: description ] ] ].
			description ])
		select: #notNil.
]

{ #category : #private }
MAPragmaBuilder >> descriptionClass: anObject [
	| descriptionClassPragmas selectors |
	
	descriptionClassPragmas := Pragma 
		allNamed: self class magritteDescriptionClassPragma 
		from: anObject class to: Object.
	
	selectors := descriptionClassPragmas collect: [ :each | each method selector ].

	^ anObject perform: (selectors first).
	"It should return only one, leaving the comment to think about other possibilities"
]

{ #category : #private }
MAPragmaBuilder >> descriptionExtensions: anObject [
	| extensionPragmas |
	
	"extensionPragmas := Pragma
		allNamed: self class magritteDescriptionExtensionPragma
		from: anObject desc class to: Object."
	extensionPragmas := Pragma
		allNamed: self class magritteDescriptionExtensionPragma
		from: anObject class to: Object.
	
	^ extensionPragmas inject: Dictionary new into: [ :extensionSelectors :each | 
		| extensionSelectorTarget |
		extensionSelectorTarget := each arguments first.
		(extensionSelectors at: extensionSelectorTarget ifAbsentPut: [ SortedCollection new ]) add: each method selector.
		extensionSelectors ].

]

{ #category : #'description building' }
MAPragmaBuilder >> for: anObject [
	| cache |
	cache := MADynamicDescriptionCache value.
	
	MADynamicDescriptionCache use: cache during: [
		^ cache at: anObject ifAbsentPut: [ self build: anObject cache: cache ] ]
]

{ #category : #private }
MAPragmaBuilder >> uniqueDescriptionSelectors: anObject [
	| descriptionPragmas selectors |
	
	"descriptionPragmas := Pragma 
		allNamed: self class magritteDescriptionPragma 
		from: (anObject desc) class to: Object."
		
	descriptionPragmas := Pragma 
		allNamed: self class magritteDescriptionPragma 
		from: anObject class to: Object.
		
	selectors := descriptionPragmas collect: [ :each | each method selector ].
	
	^ Set withAll: selectors
]
