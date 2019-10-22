Class {
	#name : #ModifiedDescription,
	#superclass : #AddressDescription,
	#category : #'Magritte-Example'
}

{ #category : #'as yet unclassified' }
ModifiedDescription >> descriptionStreet [
<magritteDescription>

^ MAStringDescription new
	accessor: #street;
	label: 'Streets of Rage';
	priority: 10;
	yourself
]
