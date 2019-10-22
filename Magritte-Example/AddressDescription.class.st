Class {
	#name : #AddressDescription,
	#superclass : #Object,
	#category : #'Magritte-Example'
}

{ #category : #'as yet unclassified' }
AddressDescription >> descriptionPlace [
<magritteDescription>

^ MAStringDescription new
	accessor: #place;
	label: 'Place';
	priority: 20;
	yourself
]

{ #category : #'as yet unclassified' }
AddressDescription >> descriptionStreet [
<magritteDescription>

^ MAStringDescription new
	accessor: #street;
	label: 'Street';
	priority: 10;
	yourself
]
