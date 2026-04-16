class_name Directed_tree extends Tree_graph

func _init(root):
	my_graph[root] = [] 

func add_node(parent_node,new_child_node):
	#var children = my_graph.get(parent_node)
	#children.append(new_child_node)
	my_graph[parent_node].append(new_child_node)
	my_graph[new_child_node] = []

func get_all_nodes_as_list():
	return my_graph.keys()

func get_all_leaves():
	var leaves = []
	for key in my_graph.keys():
		#print(my_graph.get(key).size())
		#print(my_graph.get(key).size() == 0)
		if my_graph.get(key).size() == 0:
			print("leaf")
			leaves.append(key)
	print("here are the leaves I reported: ", leaves)
	return leaves

func fetch_arb_node(node):
	'''gets an arbitrary node's children'''
	return my_graph.get(node)

func get_branch(root):
	'''quickly fetches all the children of that node and hands over a tree\n
	as if that node is the root'''
	var branch = Directed_tree.new(root)
	#var children_of_new_root = my_graph.get(root)
	#for child in children_of_new_root:
		#branch.add_node(root, child)

	var new_children_added = true
	var visited = []
	while(new_children_added):
		new_children_added = false
		for leaf in branch.get_all_leaves():
			if visited.has(leaf):
				continue
			else:
				visited.append(leaf)
			var new_kids = my_graph.get(leaf,0)
			if new_kids != 0:
				new_children_added = true
			for kid in new_kids:
				branch.add_node(leaf,kid)
	
	return branch

func prune(node):
	'''this will remove the node and all nodes after it.'''
	if my_graph.get(node).size() == 0:
		#case 1, the pruned thing is a leaf. remove it
		#	and connects all parents would have
		my_graph.erase(node)
		#iterate through the whole tree to remove
		#parent's connection.
		var nodes = get_all_nodes_as_list()
		for noode in nodes:
			var children_of_node = my_graph.get(noode)
			children_of_node.erase(node)
	else:
		#pruned thing has kids
		#remove pruned thing, and all of it's decendants, then do the 
		#steps in part one
		var branch_to_prune = get_branch(node)
		for noode in branch_to_prune.get_all_nodes_as_list():
			my_graph.erase(node)
		
		#the branch we pruned may have connections elsewere in greater tree.
		#fix that.
		var nodes = get_all_nodes_as_list()
		for noode in nodes:
			var children_of_node = my_graph.get(noode)
			for bode in branch_to_prune.get_all_nodes_as_list():
				children_of_node.erase(bode)
