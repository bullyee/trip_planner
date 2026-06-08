class ReferenceImageModel {
  final String id;
  final String poiId;
  final String authorId;
  
  final String? localPath; 
  final String? remoteUrl;  
  
  final String? metadata;   
  final String? description;
  final int createdAt;
  final bool isShared;

  ReferenceImageModel({
    required this.id,
    required this.poiId,
    required this.authorId,
    this.localPath,
    this.remoteUrl,         
    this.metadata,          
    this.description,
    required this.createdAt,
    this.isShared = false,
  });
}