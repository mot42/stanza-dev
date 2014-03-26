class MyInfStanza < TogoStanza::Stanza::Base
  SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql71dev';
  property :features do |mpo_id|
    query = <<-SPARQL.strip_heredoc
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
    
    SELECT distinct ?subject ?taxonomy_id ?title Group_Concat(?pheno,', ') as ?pheno_merged
    from <http://togogenome.org/graph/taxonomy>
    from <http://togogenome.org/graph/gold>
    from <http://togogenome.org/graph/mpo>
    where{
      ?list rdfs:subClassOf* mpo:#{mpo_id} .
      ?subject ?pre ?list .
      OPTIONAL { ?subject rdfs:label ?title } .
      OPTIONAL { ?list rdfs:label ?pheno . filter( lang(?pheno) != "ja" )}
      bind('http://identifiers.org/taxonomy/' as ?identifer) .
      bind( replace(str(?subject), ?identifer, '') as ?taxonomy_id ) .
      filter( contains(str(?subject),?identifer) )
    }
    order by ?title
    SPARQL
    
    query(SPARQL_ENDPOINT_URL, query);
  end
end
