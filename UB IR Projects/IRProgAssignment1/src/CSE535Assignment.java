import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


public class CSE535Assignment {

	public static void main(String[] args) throws IOException {
		
		//read system arguments
		File termIndexFile = new File(args[0]);
		File outputLogFile = new File(args[1]);
		int k = Integer.parseInt(args[2]);
		File queryFile = new File(args[3]);
		if(!outputLogFile.exists()){
			outputLogFile.createNewFile();
		}
		FileWriter fileWritter = new FileWriter(outputLogFile.getName(),true);
        BufferedWriter bufferWritter = new BufferedWriter(fileWritter);
		// Index 1 : ordered by increasing docID
		HashMap<String, java.util.LinkedList<Node>> index1 = new HashMap<String,java.util.LinkedList<Node>>();
		//Index 2 : ordered by decreasing term frequency
		HashMap<String, java.util.LinkedList<Node>> index2 = new HashMap<String,java.util.LinkedList<Node>>();
		// Top - K terms index:
		Map<String,Integer> topktermsMap = new HashMap<String,Integer>();
		generateIndexes(termIndexFile,index1,index2,topktermsMap);
		
		/* call to getTopK here */
		bufferWritter.write("FUNCTION: getTopK "+k);
		bufferWritter.write("\nResult: ");
		List<String> terms = getTopK(topktermsMap,k);
		bufferWritter.write(terms.get(0));
		for(int i=1;i<terms.size();i++){
			bufferWritter.write(", "+terms.get(i));
		}
		
		BufferedReader br = null;
		String sCurrentLine;
		/*	For each set of queries perform the following tasks */
		br = new BufferedReader(new FileReader(queryFile));
		while ((sCurrentLine = br.readLine()) != null) {
			String[] queryTermsArray = sCurrentLine.split("\\s");
			List<String> queryTerms=new ArrayList<String>();
			for(String queryTerm: queryTermsArray)
				queryTerms.add(queryTerm);
			
			/* Call getPostings for each query term in the query */
			for(String term_query:queryTerms){
				bufferWritter.write("\nFUNCTION: getPostings "+term_query);
				HashMap<String,List<Integer>> results = getPostings(term_query,index1,index2);
				if(results!=null){
					List<Integer> docIDList = results.get("index1");
					List<Integer> termFreqList = results.get("index2");
					bufferWritter.write("\nOrdered by doc IDs: ");
					bufferWritter.write(""+docIDList.get(0));
					for(int i=1;i<docIDList.size();i++){
						bufferWritter.write(", "+docIDList.get(i));
					}
					bufferWritter.write("\nOrdered by TF: ");
					bufferWritter.write(""+termFreqList.get(0));
					for(int i=1;i<termFreqList.size();i++){
						bufferWritter.write(", "+termFreqList.get(i));
					}
					
				} else {
					bufferWritter.write("\nTerm not found");
				}
			}
			
			
			/*	Sorting the query terms according to posting list size */
			List<String> sortedTerms = new ArrayList<String>();
			Map<String,Integer> tempMap = new HashMap<String,Integer>();
			for(String term_query:queryTerms){
				int postinListSize = topktermsMap.get(term_query);
				tempMap.put(term_query, postinListSize);
			}
			Map<String,Integer> querySortedMap = sortByComparatorAsc(tempMap);
			for(String query_term:querySortedMap.keySet()){
				sortedTerms.add(query_term);
			}
			
			
			/* Call TermAtATimeQueryAnd*/
			int optimumCompTAATAND = termAtATimeQueryAnd(sortedTerms,index2,bufferWritter,0,0);
			/* Call TermAtATimeQueryOr*/
			int optimumCompTAATOR =termAtATimeQueryOr(sortedTerms,index2,bufferWritter,0,0);
			
			/* Call TermAtATimeQueryAnd*/
			termAtATimeQueryAnd(queryTerms,index2,bufferWritter,1,optimumCompTAATAND);
			/* Call TermAtATimeQueryOr*/
			termAtATimeQueryOr(queryTerms,index2,bufferWritter,1,optimumCompTAATOR);
			/* Call DocumentAtATimeQueryAnd */
			docAtATimeQueryAnd(queryTerms,index1,bufferWritter);
			/* Call DocumentAtATimeQueryOr */
			docAtATimeQueryOr(queryTerms,index1,bufferWritter);
			
		}		
		bufferWritter.close();
	}
	
	
	/**
	 * 		Generating:
	 * 		index1: index ordered by increasing doc Id
	 * 		index2: index ordered by decreasing term frequency
	 * 		topktermsMap: Map with term as key and postinglist size as value. ordered on value.	
	 * @param termIndexFile 
	 * 
	 * */
	public static void generateIndexes(File termIndexFile, HashMap<String,java.util.LinkedList<Node>> index1,HashMap<String,java.util.LinkedList<Node>> index2, Map<String, Integer> topktermsMap){
		BufferedReader br = null;
		try {
			String sCurrentLine;
			//br = new BufferedReader(new FileReader("D:\\Masters 1st sem\\IR\\term.idx"));
			br = new BufferedReader(new FileReader(termIndexFile));
			while ((sCurrentLine = br.readLine()) != null) {
				LinkedList<Node> tempList = new LinkedList<Node>();
				LinkedList<Node> tempList2 = new LinkedList<Node>();
				String[] words = sCurrentLine.split("(\\\\c)|(\\\\m)");
				Integer postingListSize = Integer.parseInt(words[1]);
				words[2] = words[2].replaceAll("(\\[)|(\\])|(\\s)", "");
				String docs[] = words[2].split(",");
				for(String doc:docs){
					String[] docInfo = doc.split("/");
					Integer docId = Integer.parseInt(docInfo[0]);
					Integer termFreq = Integer.parseInt(docInfo[1]);
					Node tempNode = new Node(docId, termFreq);
					tempList.add(tempNode);
					tempList2.add(tempNode);
				}
				Collections.sort(tempList2, Node.NodeTermFreqComparator);
				index2.put(words[0], tempList2);
				
				Collections.sort(tempList, Node.NodeDocIDComparator);
				index1.put(words[0], tempList);
				topktermsMap.put(words[0], postingListSize);
			}
			
		    /*Testing if correct index has been generated
		    LinkedList<Node> tnodes = index1.get("zinc");
			for(Node tnode:tnodes ){
				System.out.println(tnode.getDocId()+"  "+tnode.getTermFrequency());
			}*/
			
			
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				if (br != null)br.close();
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}
	
	/**
	 * 		Function to retrieve the postings list for a query term
	 * 
	 * */
	private static HashMap<String,List<Integer>> getPostings(String term_query,
			HashMap<String, LinkedList<Node>> index1,
			HashMap<String, LinkedList<Node>> index2) {
		
		HashMap<String,List<Integer>> results = new HashMap<String,List<Integer>>();
		List<Integer> docIDList = new ArrayList<Integer>();
		List<Integer> termFreqList = new ArrayList<Integer>();
		
		if(index1==null){
			results.put("index1", null);
		} else {
			if(index1.containsKey(term_query)){
				
				LinkedList<Node> tempNodes = index1.get(term_query);
				for(Node tempNode:tempNodes){
					docIDList.add(tempNode.getDocId());
				}
				results.put("index1", docIDList);
			}
		}
		if(index2==null){
			results.put("index2", null);
			return results;
		} else{
			if(index2.containsKey(term_query)){
				LinkedList<Node> tempNodes2 = index2.get(term_query);
				for(Node tempNode:tempNodes2){
					termFreqList.add(tempNode.getDocId());
				}
				results.put("index2", termFreqList);
				return results;
			}
		}
		return null;
	}
	
	/**
	 * 		Function to retrieve the top K terms
	 * 
	 * */
	private static List<String> getTopK(Map<String, Integer> topktermsMap, int k) {
		Map<String, Integer> sortedtopkterms = sortByComparator(topktermsMap);
		List<String> topTerms = new ArrayList<String>();
		// Printing the top k terms 
		int cnt=0;
		for (Map.Entry<String, Integer> entry : sortedtopkterms.entrySet()) {
			topTerms.add(entry.getKey());
			cnt++;
			if(cnt==k)
				break;
		}
		return topTerms;
	}
	
	/**
	 * 		This function compares only two postings list at any time to generate their intersection list which is used as input
	 * 		for the next iteration
	 * @param j 
	 * */
	private static int termAtATimeQueryAnd(List<String> queryTerms,
			HashMap<String, LinkedList<Node>> index2, BufferedWriter bufferWritter, int j,int optimumCompTAATAND) throws IOException {
		int noQueryTerms = queryTerms.size();
		int comparisons = 0;
		long startTime = System.currentTimeMillis();
		if(j==1){
			bufferWritter.write("\nFUNCTION: termAtATimeQueryAnd ");
			bufferWritter.write(queryTerms.get(0));
			for(int i=1;i<queryTerms.size();i++){
				bufferWritter.write(", "+queryTerms.get(i));
			}
		}
		HashMap<String,List<Integer>> firstTermPostList = getPostings(queryTerms.get(0),null,index2);
		if(firstTermPostList==null){
			bufferWritter.write("\nTerms not found");
			return 0;
		}
		List<Integer> tempDocList = firstTermPostList.get("index2");
		List<Integer> intersectionList = new ArrayList<Integer>();
		
		for(int i=1;i<noQueryTerms;i++){
			intersectionList.clear();
			HashMap<String,List<Integer>> termPostList = getPostings(queryTerms.get(i),null,index2);
			if(termPostList==null){
				bufferWritter.write("\nTerms not found");
				return 0;
			}
			List<Integer> tempDocList2 = termPostList.get("index2"); //check for null
			for(Integer doc1:tempDocList){
				for(Integer doc2:tempDocList2){
					if(doc1.equals(doc2)){
						intersectionList.add(doc1);
						comparisons++;
						break;
					} else
						comparisons++;
				}
			}
			//tempDocList.clear();
			tempDocList = new ArrayList<Integer>(intersectionList);
		}
		
		long endTime = System.currentTimeMillis();
		double seconds = (endTime - startTime) / 1000.0;
		Collections.sort(intersectionList);
		if(j==1){
			bufferWritter.write("\n"+intersectionList.size()+" documents are found");
			bufferWritter.write("\n"+comparisons+" comparisons are made");
			bufferWritter.write("\n"+seconds+" seconds are used");
			bufferWritter.write("\n"+optimumCompTAATAND+" comparisons are made with optimization (optional bonus part)");
			bufferWritter.write("\nResult: "+intersectionList.get(0));
			for(int i=1;i<intersectionList.size();i++){
				bufferWritter.write(", "+intersectionList.get(i));
			}
		}
		return comparisons;
	}
	
	/**
	 * 		This function compares only two postings list at any time to generate their union list which is used as input
	 * 		for the next iteration
	 * @param j 
	 * */
	private static int termAtATimeQueryOr(List<String> queryTerms,
			HashMap<String, LinkedList<Node>> index2, BufferedWriter bufferWritter, int j,int optimumCompTAATOR) throws IOException {
		// TODO Optimization1 : sort by docsIDS and compare
		// TODO Optimization2 : using TF
		int noQueryTerms = queryTerms.size();
		int comparisons = 0;
		long startTime = System.currentTimeMillis();
		if(j==1){
			bufferWritter.write("\nFUNCTION: termAtATimeQueryOr ");
			bufferWritter.write(queryTerms.get(0));
			for(int i=1;i<queryTerms.size();i++){
				bufferWritter.write(", "+queryTerms.get(i));
			}
		}
		HashMap<String,List<Integer>> firstTermPostList = getPostings(queryTerms.get(0),null,index2);
		if(firstTermPostList==null){
			bufferWritter.write("\nTerms not found");
			return 0;
		}
		List<Integer> tempDocList = firstTermPostList.get("index2");
		List<Integer> unionList = new ArrayList<Integer>(tempDocList);
		int foundDocID = 0;
		for(int i=1;i<noQueryTerms;i++){
			HashMap<String,List<Integer>> termPostList = getPostings(queryTerms.get(i),null,index2);
			if(termPostList==null){
				bufferWritter.write("\nTerms not found");
				return 0;
			}
			List<Integer> tempDocList2 = termPostList.get("index2"); //check for null
			List<Integer> newTermsToAdd = new ArrayList<Integer>();
			for(Integer doc1:tempDocList2){
				for(Integer doc2:unionList){
					if(doc1.equals(doc2)){
						foundDocID = 1;
						comparisons++;
						break;
					} else
						comparisons++;
				}
				if(foundDocID==0)
					newTermsToAdd.add(doc1);
				else 
					foundDocID = 0;	
			}
			for(Integer newdoc:newTermsToAdd)
				unionList.add(newdoc);
		}
		
		long endTime = System.currentTimeMillis();
		double seconds = (endTime - startTime) / 1000.0;
		Collections.sort(unionList);
		if(j==1){
			bufferWritter.write("\n"+unionList.size()+" documents are found");
			bufferWritter.write("\n"+comparisons+" comparisons are made");
			bufferWritter.write("\n"+seconds+" seconds are used");
			bufferWritter.write("\n"+optimumCompTAATOR+" comparisons are made with optimization (optional bonus part)");
			bufferWritter.write("\nResult: "+unionList.get(0));
			for(int i=1;i<unionList.size();i++){
				bufferWritter.write(", "+unionList.get(i));
			}
		}
		return comparisons;
	}

	/**
	 * 	This function compares all postings list at any time to generate their intersection list.
	 * 	When any list reaches its end we get our final intersection list.
	 * 	If any iterator has reached the end() of its corresponding set, you are done. 
	 * 	Thus, it can be assumed that all iterators are valid.
	 * 	Take the first iterator's value as the next candidate value x.
	 * 	Move through the list of iterators and use findClosest to find the first element at least as big as x.
	 * 	If the value is bigger than x make it the new candidate value,increment all other pointers and search again in the sequence of iterators.
	 * 	If all iterators are on value x you found an element of the intersection: Record it, increment all iterators, start over.
	 * 		
	 * */
	private static int docAtATimeQueryAnd(List<String> queryTerms,
			HashMap<String, LinkedList<Node>> index1, BufferedWriter bufferWritter) throws IOException {
		// TODO Auto-generated method stub
		bufferWritter.write("\nFUNCTION: docAtATimeQueryAnd ");
		bufferWritter.write(queryTerms.get(0));
		for(int i=1;i<queryTerms.size();i++){
			bufferWritter.write(", "+queryTerms.get(i));
		}
		
		int noQueryTerms = queryTerms.size();
		int comparisons = 0;
		long startTime = System.currentTimeMillis();
		List<List<Integer>> mainList = new ArrayList<List<Integer>>();
		for(int i=0;i<noQueryTerms;i++){
			HashMap<String,List<Integer>> postList = getPostings(queryTerms.get(i),index1,null);
			if(!postList.containsKey("index1")){
				bufferWritter.write("\nTerms not found");
				return 0;
			}
			List<Integer> tempDocList = postList.get("index1");
			mainList.add(tempDocList);
		}
		List<Integer> intersectionList = new ArrayList<Integer>();
		/*Storing pointer positions for each query's posting list*/
		Integer[] pointerArr = new Integer[noQueryTerms];
		/*Initialize pointer array*/
		for(int i=0;i<noQueryTerms;i++){
			pointerArr[i]=0;
		}
		/* Flag for exiting the loop. Indicates end of posting list for any query term*/
		int flag = 0;
		int x = mainList.get(0).get(0);
		//System.out.println("Initial X : "+x);
		int maxVal = x;
		List<Integer> maxli = new ArrayList<Integer>();
		int flag2=0;
		while(flag!=1){
			// Checking for end of each posting list  
			for(int j=0;j<noQueryTerms;j++){
				//end of list reached. No need to increment other pointers.
				if(pointerArr[j]>=mainList.get(j).size()){
					flag=1;
					break;
				}
			}
			if(flag==1)
				break;
			int foundDoc = 0;
			maxVal = x;
			maxli.clear();
			for(int i=0;i<noQueryTerms;i++){
				List<Integer> li = mainList.get(i);
				int[] result = findClosestX(li,x,comparisons,pointerArr[i]);
				int position = result[0];
				comparisons = result[1];
				if(position==-1){
					flag=1;
					break;
				}
				if(li.get(position)==x){
					//comparisons++;
					foundDoc++;
					pointerArr[i] = position;
					if(foundDoc==noQueryTerms){
						intersectionList.add(x);
						for(int j=0;j<noQueryTerms;j++){
							pointerArr[j] = pointerArr[j] + 1;  
						}
						if(pointerArr[0]<mainList.get(0).size()){
							x = mainList.get(0).get(pointerArr[0]);
							maxVal = x;
						}
						flag2=1;
						break;
					}
				} else {
					if(maxVal<li.get(position)){
						maxVal = li.get(position);
						maxli.add(i);
					}else if(maxVal==li.get(position)){
						maxli.add(i);
					}
				}	
			}
			if(flag2==1){
				flag2=0;
			} else {
				x = maxVal;
				for(int j=0;j<noQueryTerms;j++){
					if(!maxli.contains(j)){
						pointerArr[j] = pointerArr[j] + 1; 
					}
				}
			}
		}
		long endTime = System.currentTimeMillis();
		double seconds = (endTime - startTime) / 1000.0;
		Collections.sort(intersectionList);
		bufferWritter.write("\n"+intersectionList.size()+" documents are found");
		bufferWritter.write("\n"+comparisons+" comparisons are made");
		bufferWritter.write("\n"+seconds+" seconds are used");
		bufferWritter.write("\nResult: "+intersectionList.get(0));
		for(int i=1;i<intersectionList.size();i++){
			bufferWritter.write(", "+intersectionList.get(i));
		}
		
		return 1;
	}

	/**
	 * 	Function to find the no equal to or just greater than x
	 *  returns -1 if list ends and no greater no is found
	 * 	
	 * */
	private static int[] findClosestX(List<Integer> li, int x,int comparisons,int pointer) {
		int nearest = -1;
		int bestDistanceFoundYet = Integer.MAX_VALUE;
		int[] result = new int[2];
		// We iterate on the array
		for (int i = pointer; i < li.size(); i++) {
		  // if we found the desired number, we return it.
		  if (li.get(i) == x) {
			  comparisons++;
			  result[0] = i;
			  result[1] = comparisons;
		      return result;
		  } else {
			  if(li.get(i)>x){
				  comparisons++;
			    // else, we consider the difference between the desired number and the current number in the array.
			    int d = Math.abs(x - li.get(i));
			    if (d < bestDistanceFoundYet) {
			      // For the moment, this value is the nearest to the desired number
			      bestDistanceFoundYet = d; // Assign new best distance
			      nearest = i;
			      break;
			    }
			  }  
		  }
		}
		result[0] = nearest;
		result[1] = comparisons;
		return result;
	}

	/**
	 * 	This function compares all postings list at any time to generate their union list 
	 * 	When all lists reach their end we get our final union list.
	 * 	If any iterator has reached the end() of its corresponding set, we add all elements from pointer 
	 * 	till end to union list and then remove it. 
	 * 	Take the first iterator's value as the next candidate value x.
	 * 	Move through the list of iterators and use findClosest to find the first element at least as big as x.
	 *  Add smaller value to the union list
	 * 	If the value is bigger than x make it the new candidate value,increment all other pointers 
	 * 	and search again in the sequence of iterators.
	 * 	If all iterators are on value x you found an element of the intersection: Add it, increment 
	 *  all iterators, start over.
	 * 		
	 * */
	private static int docAtATimeQueryOr(List<String> queryTerms,
			HashMap<String, LinkedList<Node>> index1, BufferedWriter bufferWritter) throws IOException {
		
		bufferWritter.write("\nFUNCTION: docAtATimeQueryOr ");
		bufferWritter.write(queryTerms.get(0));
		for(int i=1;i<queryTerms.size();i++){
			bufferWritter.write(", "+queryTerms.get(i));
		}
		
		int noQueryTerms = queryTerms.size();
		int comparisons = 0;
		long startTime = System.currentTimeMillis();
		List<List<Integer>> mainList = new ArrayList<List<Integer>>();
		for(int i=0;i<noQueryTerms;i++){
			HashMap<String,List<Integer>> postList = getPostings(queryTerms.get(i),index1,null);
			if(!postList.containsKey("index1")){
				bufferWritter.write("\nTerms not found");
				return 0;
			}
			List<Integer> tempDocList = postList.get("index1");
			mainList.add(tempDocList);
		}
		List<Integer> unionList = new ArrayList<Integer>();
		/*Storing pointer positions for each query's posting list*/
		List<Integer> pointerArr = new ArrayList<Integer>(noQueryTerms);
		/*Initialize pointer array*/
		for(int i=0;i<noQueryTerms;i++){
			pointerArr.add(0);
		}
		
		List<Integer> remainingLists = new ArrayList<Integer>();
		for(int i=0;i<noQueryTerms;i++)
			remainingLists.add(i);
		/* Flag for exiting the loop. Indicates end of posting list for any query term*/
		int flag = 0;
		int x = mainList.get(0).get(0);
		unionList.add(x);
		int maxVal = x;
		List<Integer> maxli = new ArrayList<Integer>();
		int flag2=0;
		int querytermsremaining=noQueryTerms;
		int traversedFlag = 0;
		while(flag!=1){
			if(remainingLists.size()==1){
				List<Integer> li = mainList.get(remainingLists.get(0));
				for(int i=pointerArr.get(remainingLists.get(0));i<li.size();i++){
					int found = inUnionList(unionList,li.get(i));
					if(found==0)
						unionList.add(li.get(i));
					
				}
				flag=1;
			}
			// Checking for end of each posting list  
			for(int j=0;j<noQueryTerms;j++){
				//end of list reached. No need to increment other pointers.
				if(pointerArr.get(j)>=mainList.get(j).size()){
					for(int no=0;no<remainingLists.size();no++){
						if(remainingLists.get(no).equals(j)){
							remainingLists.remove(no);
							querytermsremaining--;
						}	
					}
					
					//traversedFlag=1;
					//break;
				}
			}
			if(flag==1)
				break;
			
			int foundDoc = 0;
			maxVal = x;
			maxli.clear();
			//Map<Integer,Integer> nos = new HashMap<Integer,Integer>();
			for(int i=0;i<querytermsremaining;i++){
				List<Integer> li = mainList.get(remainingLists.get(i));
				int[] result = findClosestXOr(li,x,comparisons,pointerArr.get(i),unionList);
				int position = result[0];
				comparisons = result[1];
				if(position==-1){
					for(int no=0;no<remainingLists.size();no++){
						if(remainingLists.get(no).equals(i))
							remainingLists.remove(no);
					}
					querytermsremaining--;
					traversedFlag=1;
					break;
				}
				if(li.get(position)==x){
					//comparisons++;
					foundDoc++;
					//adding doc
					int found = inUnionList(unionList,li.get(position));
					if(found==0)
						unionList.add(li.get(position));
					
					
					pointerArr.set(i, position);
					if(foundDoc==noQueryTerms){
						for(int j=0;j<noQueryTerms;j++){
							pointerArr.set(j, pointerArr.get(j) + 1);  
						}
						if(pointerArr.get(0)<mainList.get(0).size()){
							x = mainList.get(0).get(pointerArr.get(0));
							maxVal = x;
						}
						flag2=1;
						break;
					}
				} else {
					if(maxVal<li.get(position)){
						maxVal = li.get(position);
						maxli.add(i);
					}else if(maxVal==li.get(position)){
						maxli.add(i);
					}
				}	
			}
			if(traversedFlag==1){
				traversedFlag=0;
			}
			if(flag2==1){
				flag2=0;
			} else {
				x = maxVal;
				for(int j=0;j<remainingLists.size();j++){
					int k = remainingLists.get(j);
					if(!maxli.contains(k)){
						pointerArr.set(k, pointerArr.get(k) + 1); 
					}
				}
			}
		}
	
		long endTime = System.currentTimeMillis();
		double seconds = (endTime - startTime) / 1000.0;
		bufferWritter.write("\n"+unionList.size()+" documents are found");
		bufferWritter.write("\n"+comparisons+" comparisons are made");
		bufferWritter.write("\n"+seconds+" seconds are used");
		Collections.sort(unionList);
		bufferWritter.write("\nResult: "+unionList.get(0));
		for(int i=1;i<unionList.size();i++){
			bufferWritter.write(", "+unionList.get(i));
		}
		
		return 1;
	}

	private static int inUnionList(List<Integer> unionList, Integer x) {
		//Collections.sort(unionList);
		for(int j =0;j<unionList.size();j++){
			if(unionList.get(j).equals(x)){
				return 1;
			}
			//if(unionList.get(j)>x)
			//	break;
		  }
		return 0;
	}

	private static int[] findClosestXOr(List<Integer> li, int x,int comparisons,int pointer,List<Integer> unionList) {
		int nearest = -1;
		int bestDistanceFoundYet = Integer.MAX_VALUE;
		//Collections.sort(unionList);
		int[] result = new int[2];
		// We iterate on the array...
		for (int i = 0; i < li.size(); i++) {
		  // if we found the desired number, we return it.
		  if (li.get(i) == x) {
			  comparisons++;
			  result[0] = i;
			  result[1] = comparisons;
		      return result;
		  } else {
			  if(li.get(i)>x){
				  comparisons++;
			    // else, we consider the difference between the desired number and the current number in the array.
			    int d = Math.abs(x - li.get(i));
			    if (d < bestDistanceFoundYet) {
			      // For the moment, this value is the nearest to the desired number...
			      bestDistanceFoundYet = d; // Assign new best distance...
			      nearest = i;
			      break;
			    }
			  } else {
				  /* Smaller term encountered. Add it to the union list */
				  int found = inUnionList(unionList,li.get(i));
					if(found==0)
						unionList.add(li.get(i));
					
			  } 
		  }
		}
		
		/* Term not found and end of list reached. Just add all remaining terms to union list*/
		if(nearest==-1){
			for (int i = pointer; i < li.size(); i++){
				int found = inUnionList(unionList,li.get(i));
				if(found==0)
					unionList.add(li.get(i));
				
				
			}
		}
		result[0] = nearest;
		result[1] = comparisons;
		return result;
	}
	
		
	/**
	 * 		Used for sorting the top K terms map on descending key values
	 * 
	 * */
	private static Map<String, Integer> sortByComparator(Map<String, Integer> unsortMap) {
		// Convert Map to List
		List<Map.Entry<String, Integer>> list = 
			new LinkedList<Map.Entry<String, Integer>>(unsortMap.entrySet());
		// Sort list with comparator, to compare the Map values
		Collections.sort(list, new Comparator<Map.Entry<String, Integer>>() {
			public int compare(Map.Entry<String, Integer> o1,
                                           Map.Entry<String, Integer> o2) {
				return (o2.getValue()).compareTo(o1.getValue());
			}
		});
		// Convert sorted map back to a Map
		Map<String, Integer> sortedMap = new LinkedHashMap<String, Integer>();
		for (Iterator<Map.Entry<String, Integer>> it = list.iterator(); it.hasNext();) {
			Map.Entry<String, Integer> entry = it.next();
			sortedMap.put(entry.getKey(), entry.getValue());
		}
		return sortedMap;
	}
	/**
	 * 		Used for sorting the top K terms map on ascending key values
	 * 
	 * */
	private static Map<String, Integer> sortByComparatorAsc(Map<String, Integer> unsortMap) {
		// Convert Map to List
		List<Map.Entry<String, Integer>> list = 
			new LinkedList<Map.Entry<String, Integer>>(unsortMap.entrySet());
		// Sort list with comparator, to compare the Map values
		Collections.sort(list, new Comparator<Map.Entry<String, Integer>>() {
			public int compare(Map.Entry<String, Integer> o1,
                                           Map.Entry<String, Integer> o2) {
				return (o1.getValue()).compareTo(o2.getValue());
			}
		});
		// Convert sorted map back to a Map
		Map<String, Integer> sortedMap = new LinkedHashMap<String, Integer>();
		for (Iterator<Map.Entry<String, Integer>> it = list.iterator(); it.hasNext();) {
			Map.Entry<String, Integer> entry = it.next();
			sortedMap.put(entry.getKey(), entry.getValue());
		}
		return sortedMap;
	}
}

class Node implements Comparable<Node>{

	private Integer docId;
	private Integer termFrequency;
	public Node(Integer docId,Integer termFrequency){
		this.docId = docId;
		this.termFrequency = termFrequency;
	}
	public Integer getDocId() {
		return docId;
	}
	public void setDocId(Integer docId) {
		this.docId = docId;
	}
	public Integer getTermFrequency() {
		return termFrequency;
	}
	public void setTermFrequency(Integer termFrequency) {
		this.termFrequency = termFrequency;
	}
	@Override
	public int compareTo(Node node2) {
		return this.docId-node2.docId;
	}
	public static Comparator<Node> NodeDocIDComparator = new Comparator<Node>() {
		public int compare(Node node1, Node node2) {
			return node1.compareTo(node2);
		}
	};
	public static Comparator<Node> NodeTermFreqComparator = new Comparator<Node>() {
		public int compare(Node node1, Node node2) {
			return node2.termFrequency-node1.termFrequency;// node2.compareTo(node1);
		}
	};
}
