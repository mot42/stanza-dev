class GmoGeneralStanza < TogoStanza::Stanza::Base
	property :medium_information do |med_id|
		medium_list = query("http://ep.dbcls.jp/sparql71dev", <<-SPARQL.strip_heredoc)
		PREFIX gmo: <http://purl.jp/bio/11/gmo#>

		SELECT DISTINCT ?medium_id ?medium_type_label ?medium_name
		FROM <http://togogenome.org/graph/brc>
		FROM <http://togogenome.org/graph/gmo>
		WHERE
		{
			?medium gmo:GMO_000101 ?medium_id .
			?medium gmo:GMO_000111 ?medium_type .
			?medium_type rdfs:label ?medium_type_label FILTER (lang(?medium_type_label) = "en") .
			OPTIONAL { ?medium gmo:GMO_000102 ?medium_name } .
			filter( ?medium_id = "#{med_id}" )
		}
		SPARQL
		
		ingredient_list = query("http://ep.dbcls.jp/sparql71dev", <<-SPARQL.strip_heredoc)
		PREFIX mccv: <http://purl.jp/bio/01/mccv#>
		PREFIX gmo: <http://purl.jp/bio/11/gmo#>
		SELECT ?medium_id ?classification ?class_label ?ingredient_label
		FROM <http://togogenome.org/graph/brc>
		FROM <http://togogenome.org/graph/gmo>
		WHERE {
			VALUES ?classification { gmo:GMO_000015 gmo:GMO_000016 gmo:GMO_000008 gmo:GMO_000009 }
			?medium gmo:GMO_000101 ?medium_id .
			?medium gmo:GMO_000104 ?ingredient .
			?ingredient rdfs:subClassOf* ?classification .
			?ingredient rdfs:label ?ingredient_label FILTER (lang(?ingredient_label) = "en") .
			?classification rdfs:label ?class_label .
			filter( ?medium_id = "#{med_id}" )
		}
		GROUP BY ?medium_id ?classification ?class_label
		SPARQL
		
		ingredients = ingredient_list.group_by {|hash| hash[:medium_id] }
		ingredients_classes = ["GMO_000015", "GMO_000016", "GMO_000008", "GMO_000009"]
		result = medium_list.map {|hash|
			row = []
			row.push({:row_key => "Medium ID", :row_value => hash[:medium_id], :is_array => false})
			row.push({:row_key => "Medium name", :row_value => hash[:medium_name], :is_array => false})
			row.push({:row_key => "Medium type", :row_value => hash[:medium_type_label], :is_array => false})
			
			classed_ingredients = ingredients[hash[:medium_id]].group_by{|ingred| ingred[:classification].split("#").last}
			ingredients_classes.each{ |classes|
				classification = classed_ingredients[classes]
				next unless classification
				
				listrow = {:row_key => classification.at(0).fetch(:class_label,""), :row_value => [], :is_array => true}
				classification.each{|ingres|
					listrow[:row_value].push(ingres[:ingredient_label])
				}
				row.push(listrow)
			}
			row
		}
		result
	end
end
