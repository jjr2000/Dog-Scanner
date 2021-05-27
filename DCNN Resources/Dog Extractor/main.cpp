#include <string>
#include <vector>
#include <exception>
#include <iostream>
#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/xml_parser.hpp>
#include <boost/foreach.hpp>
#include <filesystem>
#include <opencv2/opencv.hpp>

//#include <windows.h>

namespace pt = boost::property_tree;

using namespace std;

struct segment{
    segment(string breed, int xmin, int ymin, int xmax, int ymax): breed(breed), xmin(xmin), ymin(ymin), xmax(xmax), ymax(ymax){}
    string breed;
    int xmin;
    int ymin;
    int xmax;
    int ymax;
};

struct annotation
{
    vector<segment> segments;
    void load(const std::string &filename);
};

void annotation::load(const std::string &file)
{
     // Create empty property tree object
    pt::ptree tree;

    // Parse the XML into the property tree.
    pt::read_xml(file, tree);

    // Use get_child to find the node containing the modules, and iterate over
    // its children. If the path cannot be resolved, get_child throws.
    // A C++11 for-range loop would also work.
    BOOST_FOREACH(pt::ptree::value_type &v, tree.get_child("annotation")) {
        if(v.first == "object")
            segments.push_back(segment(
                v.second.get<string>("name"),
                v.second.get<int>("bndbox.xmin"),
                v.second.get<int>("bndbox.ymin"),
                v.second.get<int>("bndbox.xmax"),
                v.second.get<int>("bndbox.ymax")
                ));
    }
}

int main()
{
    //char buf[256];
    //GetCurrentDirectoryA(256, buf);

    const string dataset_dir = "..\\Original Dataset\\"; //string(buf) + 
    const string export_dir = "..\\Processed Dataset\\";
    vector<string> folders;
    for(const auto & p : filesystem::recursive_directory_iterator(dataset_dir + "Annotations"))
        if (filesystem::is_directory(p.path()))
        {
            string str_path = p.path().string();
            const size_t last_slash_idx = str_path.find_last_of("\\/");
            str_path.erase(0, last_slash_idx + 1);
            
            for(const auto & f : filesystem::recursive_directory_iterator(p.path()))
            {
                annotation an; 
                an.load(f.path().string());

                string str_fn = f.path().string();
                const size_t last_slash_idx = str_fn.find_last_of("\\/");
                str_fn.erase(0, last_slash_idx + 1);

                string src = dataset_dir + "Images\\" + str_path + "\\" + str_fn + ".jpg";
                cout << src << endl;
                cv::Mat img = cv::imread(src);
                int i=0;

                for(segment s : an.segments)
                {
                    string dest_dir = export_dir + s.breed;
                    if (!filesystem::is_directory(dest_dir) || !filesystem::exists(dest_dir)) { // Check if src folder exists
                        filesystem::create_directory(dest_dir); // create src folder
                    }

                    // Setup a rectangle to define your region of interest
                    cv::Rect myROI(s.xmin, s.ymin, s.xmax-s.xmin, s.ymax-s.ymin);

                    // Crop the full image to that image contained by the rectangle myROI
                    // Note that this doesn't copy the data
                    cv::Mat croppedImage = img(myROI);
                    string dest = dest_dir + "\\" + str_fn + "_" + to_string(i++) + ".jpg";
                    cv::imwrite(dest, croppedImage);
                }
            }

        }

    cout << "Hello World" << endl;
}