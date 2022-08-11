/******************************************************************************
 * Project:  libspatialindex - A C++ library for spatial indexing
 * Author:   Marios Hadjieleftheriou, mhadji@gmail.com
 ******************************************************************************
 * Copyright (c) 2002, Marios Hadjieleftheriou
 *
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
******************************************************************************/

// NOTE: Please read README.txt before browsing this code.

#include <cstring>
#include <chrono>

// include library header file.
#include <spatialindex/SpatialIndex.h>

using namespace SpatialIndex;

#define INSERT 1
#define DELETE 0
#define QUERY 2

// example of a Visitor pattern.
// see RTreeQuery for a more elaborate example.
class MyVisitor : public IVisitor
{
public:
	void visitNode(const INode& /* n */) override {}

	void visitData(const IData& d) override
	{
		std::cout << d.getIdentifier() << std::endl;
			// the ID of this data entry is an answer to the query. I will just print it to stdout.
	}

	void visitData(std::vector<const IData*>& /* v */) override {}
};


// Strategy for traversing LEAVES ONLY. write Leaves' MBR to std output, cout. Bash script redirect cout to a "pltDynLevel0" file
class MyQueryStrategy3: public SpatialIndex::IQueryStrategy {

private:
	std::queue<id_type> ids;

public:
	void getNextEntry(const IEntry& entry, id_type& nextEntry, bool& hasNext) {
		IShape* ps;
		entry.getShape(&ps);
		Region* pr = dynamic_cast<Region*>(ps);

		const INode* n = dynamic_cast<const INode*>(&entry);
		// traverse only index nodes at levels 1 and higher.
		if (n != 0 && n->getLevel() > 0) {
			for (uint32_t cChild = 0; cChild < n->getChildrenCount();
					cChild++) {
				ids.push(n->getChildIdentifier(cChild));
			}
		}
		else{
			std::cout << (double)pr->m_pLow[0] << " " << (double)pr->m_pLow[1] << std::endl;
			std::cout << (double)pr->m_pHigh[0] << " " << (double)pr->m_pLow[1] << std::endl;
			std::cout << (double)pr->m_pHigh[0] << " " << (double)pr->m_pHigh[1] << std::endl;
			std::cout << (double)pr->m_pLow[0] << " " << (double)pr->m_pHigh[1] << std::endl;
			std::cout << (double)pr->m_pLow[0] << " " << (double)pr->m_pLow[1] << std::endl << std::endl;
		}
		if (!ids.empty()) {
					nextEntry = ids.front();
					ids.pop();
					hasNext = true;
		}
		else hasNext = false;
		delete ps;
	}
};

int main(int argc, char** argv)
{
	try
	{
		if (argc != 8)
		{
			std::cerr << "Usage: " << argv[0] << " input_file tree_file idx_pageSize  cache_size capacity query_type [intersection | 10NN | selfjoin | contains] isPlotting." << std::endl;
			return -1;
		}

		uint32_t idx_pageSize = atoi(argv[3]);  // i.e. idx node size. = number of system pages in the index node. (sys-unit-page=4K (assume system page size is 4K))
		uint32_t cache_size = atoi(argv[4]);  // max. number of idx-pages in the buffer

		uint32_t queryType = 0;
		if (strcmp(argv[6], "intersection") == 0) queryType = 0;
		else if (strcmp(argv[6], "10NN") == 0) queryType = 1;
		else if (strcmp(argv[6], "selfjoin") == 0) queryType = 2;
		else if (strcmp(argv[6], "contains") == 0) queryType = 3;
		else
		{
			std::cerr << "Unknown query type." << std::endl;
			return -1;
		}

		std::ifstream fin(argv[1]);
		if (! fin)
		{
			std::cerr << "Cannot open data file " << argv[1] << "." << std::endl;
			return -1;
		}

		// Create a new storage manager with the provided base name and a 4K page size.
		std::string baseName = argv[2];
		IStorageManager* diskfile = StorageManager::createNewDiskStorageManager(baseName, 4096);

		StorageManager::IBuffer* file = StorageManager::createNewRandomEvictionsBuffer(*diskfile, 10, false);
			// applies a main memory random buffer on top of the persistent storage manager
			// (LRU buffer, etc can be created the same way).

		// Create a new, empty, RTree with dimensionality 2, minimum load 70%, using "file" as
		// the StorageManager and the RSTAR splitting policy.
		id_type indexIdentifier;

		auto t1 = std::chrono::high_resolution_clock::now(); //utku
		ISpatialIndex* tree = RTree::createNewRTree(*file, 0.7, atoi(argv[5]), atoi(argv[5]), 2, SpatialIndex::RTree::RV_RSTAR, indexIdentifier);

		size_t count = 0;
		id_type id;
		uint32_t op;
		double x1, x2, y1, y2;
		double plow[2], phigh[2];

		while (fin)
		{
			fin >> op >> id >> x1 >> y1 >> x2 >> y2;
			if (! fin.good()) continue; // skip newlines, etc.

			if (op == INSERT)
			{
				plow[0] = x1; plow[1] = y1;
				phigh[0] = x2; phigh[1] = y2;
				Region r = Region(plow, phigh, 2);

				std::ostringstream os;
				os << r;
				std::string data = os.str();
					// associate some data with this region. I will use a string that represents the
					// region itself, as an example.
					// NOTE: It is not necessary to associate any data here. A null pointer can be used. In that
					// case you should store the data externally. The index will provide the data IDs of
					// the answers to any query, which can be used to access the actual data from the external
					// storage (e.g. a hash table or a database table, etc.).
					// Storing the data in the index is convinient and in case a clustered storage manager is
					// provided (one that stores any node in consecutive pages) performance will improve substantially,
					// since disk accesses will be mostly sequential. On the other hand, the index will need to
					// manipulate the data, resulting in larger overhead. If you use a main memory storage manager,
					// storing the data externally is highly recommended (clustering has no effect).
					// A clustered storage manager is NOT provided yet.
					// Also you will have to take care of converting you data to and from binary format, since only
					// array of bytes can be inserted in the index (see RTree::Node::load and RTree::Node::store for
					// an example of how to do that).

				//tree->insertData((uint32_t)(data.size() + 1), reinterpret_cast<const uint8_t*>(data.c_str()), r, id);

				tree->insertData(0, 0, r, id);
					// example of passing zero size and a null pointer as the associated data.
				//utku: If you do not write some data, capacity=92 holds only 1 4K-disk page. Otherwise, if you write some data 1 node would need >1 disk page.
			}
			else if (op == DELETE)
			{
				plow[0] = x1; plow[1] = y1;
				phigh[0] = x2; phigh[1] = y2;
				Region r = Region(plow, phigh, 2);

				if (tree->deleteData(r, id) == false)
				{
					std::cerr << "******ERROR******" << std::endl;
					std::cerr << "Cannot delete id: " << id << " , count: " << count << std::endl;
					return -1;
				}
			}
			else if (op == QUERY)
			{
				plow[0] = x1; plow[1] = y1;
				phigh[0] = x2; phigh[1] = y2;

				MyVisitor vis;

				if (queryType == 0)
				{
					Region r = Region(plow, phigh, 2);
					tree->intersectsWithQuery(r, vis);
						// this will find all data that intersect with the query range.
				}
				else if (queryType == 1)
				{
					Point p = Point(plow, 2);
					tree->nearestNeighborQuery(10, p, vis);
						// this will find the 10 nearest neighbors.
				}
				else if(queryType == 2)
				{
					Region r = Region(plow, phigh, 2);
					tree->selfJoinQuery(r, vis);
				}
				else
				{
					Region r = Region(plow, phigh, 2);
					tree->containsWhatQuery(r, vis);
						// this will find all data that is contained by the query range.
				}
			}

			if ((count % 1000) == 0)
				std::cerr << count << std::endl;

			count++;
		}

		std::cerr << "Operations: " << count << std::endl;
		std::cerr << *tree;
		std::cerr << "Buffer hits: " << file->getHits() << std::endl;
		std::cerr << "Index ID: " << indexIdentifier << std::endl;

		// utku:
		auto t2 = std::chrono::high_resolution_clock::now();
		auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
				t2 - t1).count();
		std::cerr << "Time elapsed (msec) for dynamic loading is : " << duration
				<< std::endl;

//		bool ret = tree->isIndexValid();
//		if (ret == false) std::cerr << "ERROR: Structure is invalid!" << std::endl;
//		else std::cerr << "The stucture seems O.K." << std::endl;

		// New strategy for traversing Leaves Only. I want to plot them w/ gnuplot.
		// Bunu acarsan RTreload Disk IO numTotalNodes kadar artıyor. Cünkü burda bütün ağacı dolaşıyoruz.!!!
		if (atoi(argv[7])) {
			MyQueryStrategy3 qs;
			tree->queryStrategy(qs);
		}


		delete tree;
		delete file;
		delete diskfile;
			// delete the buffer first, then the storage manager
			// (otherwise the the buffer will fail trying to write the dirty entries).
	}
	catch (Tools::Exception& e)
	{
		std::cerr << "******ERROR******" << std::endl;
		std::string s = e.what();
		std::cerr << s << std::endl;
		return -1;
	}

	return 0;
}
