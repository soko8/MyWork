package set;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AllSubset {

	// https://www.geeksforgeeks.org/finding-all-subsets-of-a-given-set-in-java/
	public static void main(String[] args) {
		int n = 10;

		var chars = new StringBuilder();
		for (var i = 0; i < n; i++) {
			chars.append(i);
		}

		char set[] = new char[chars.length()];
		chars.getChars(0, chars.length(), set, 0);
		
//		printSubsets(set);
		new AllSubset().getAllSubsets(set);

	}

	// Print all subsets of given set[]
	static void printSubsets(char set[]) {
		int n = set.length;

		// Run a loop for printing all 2^n subsets one by one
		for (int i = 0; i < (1 << n); i++) {
			System.out.print("{ ");

			// Print current subset
			for (int j = 0; j < n; j++)

				// (1<<j) is a number with jth bit 1
				// so when we 'and' them with the
				// subset number we get which numbers
				// are present in the subset and which are not
				if ((i & (1 << j)) > 0)
					System.out.print(set[j] + " ");

			System.out.println("}");
		}
	}
	
	// Print all subsets of given set[]
	public List<List<Character>> getAllSubsets(char set[]) {
		var result = new ArrayList<List<Character>>();
		int n = set.length;

		// Run a loop for printing all 2^n subsets one by one
		for (int i = 0; i < (1 << n); i++) {
			var subset = new ArrayList<Character>();

			// Print current subset
			for (int j = 0; j < n; j++) {

				// (1<<j) is a number with jth bit 1
				// so when we 'and' them with the
				// subset number we get which numbers
				// are present in the subset and which are not
				if ((i & (1 << j)) > 0) {
					subset.add(set[j]);
				}
			}

			result.add(subset);
		}
		
		Collections.sort(result, (s1, s2) -> {
			var l1 = (List<Character>) s1;
			var l2 = (List<Character>) s2;
			var diffSize = l1.size() - l2.size();
			if (0 != diffSize) {
				return diffSize;
			}
			
			var indexDiff = 0;
			for (var i = 0; i < l1.size(); i++) {
				if (l1.get(i).equals(l2.get(i))) {
					continue;
				}
				indexDiff = i;
				break;
			}
			return l1.get(indexDiff) - l2.get(indexDiff);
			});
		System.out.println(result);
		return result;
	}

}
