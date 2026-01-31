
import sys

def search_file(filepath, queries):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        results = {}
        for q in queries:
            results[q] = []

        for i, line in enumerate(lines):
            for q in queries:
                if q in line:
                    context = lines[max(0, i-2):min(len(lines), i+3)]
                    results[q].append({
                        'line': i+1,
                        'content': line.strip(),
                        'context': "".join(context)
                    })
                    if len(results[q]) >= 10: # limit to 10 matches per query
                        break
        
        for q, matches in results.items():
            print(f"--- Matches for '{q}' ---")
            if not matches:
                print("No matches found.")
            for m in matches:
                print(f"Line {m['line']}: {m['content']}")
                # print(f"Context:\n{m['context']}\n")
            print("\n")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python search.py <file> <query1> <query2> ...")
        sys.exit(1)
    
    queries = sys.argv[2:]
    search_file(sys.argv[1], queries)
