class_name Tree_graph extends Object

var my_graph : Dictionary

func _init(root):
	my_graph[root] = [] 

func add_node(parent_node,new_child_node):
	#var children = my_graph.get(parent_node)
	#children.append(new_child_node)
	my_graph[parent_node].append(new_child_node)
	my_graph[new_child_node] = []
	my_graph[new_child_node].append(parent_node)
	#my_graph.set(parent_node,children)

func get_all_nodes_as_list():
	return my_graph.keys()
