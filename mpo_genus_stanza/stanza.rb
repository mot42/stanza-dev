class MpoGenusStanza < TogoStanza::Stanza::Base
  SPARQL_ENDPOINT_URL = 'http://ep.dbcls.jp/sparql71dev';
  property :features do |mpo|
    query = <<-SPARQL.strip_heredoc
	PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
	PREFIX mpo:  <http://purl.jp/bio/01/mpo#>
	PREFIX taxonomy:  <http://ddbj.nig.ac.jp/ontologies/taxonomy/>

	SELECT distinct ?genus count(*) as ?cnt
	from <http://togogenome.org/graph/taxonomy>
	from <http://togogenome.org/graph/gold>
	from <http://togogenome.org/graph/mpo>
	where{
		?list rdfs:subClassOf* mpo:#{mpo} .
		?subject ?pre ?list .
		OPTIONAL { ?subject rdfs:label ?title } .
		bind('http://identifiers.org/taxonomy/' as ?identifer) .
		filter( contains(str(?subject),?identifer) ) .

		OPTIONAL {
			?subject rdfs:subClassOf* ?list2 .
			?list2 taxonomy:rank taxonomy:Genus .
			?list2 rdfs:label ?genus
		}
	}
	group by ?genus
	order by desc(?cnt)
    SPARQL
    
    query(SPARQL_ENDPOINT_URL, query);
  end
end
