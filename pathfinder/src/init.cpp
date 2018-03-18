#include <core/Godot.hpp>
#include <Reference.hpp>
#include <set>
#include <map>
#include <queue>

using namespace godot;
using namespace std;

class Pathfinder : public GodotScript<Reference> {
    GODOT_CLASS(Pathfinder);
public:
    Pathfinder() { }
    
    float _g_score(const Variant& from, const Variant& to) {
        return this->owner->call("_g_score", from, to, 2);
    }
    
    float _h_score(const Variant& from, const Variant& to) {
        return this->owner->call("_h_score", from, to, 2);
    }
    
    bool _is_passable(const Variant& pos) {
        return this->owner->call("_is_passable", pos, 1);
    }

    Array _neighbors(const Variant& pos) {
        return this->owner->call("_get_neighbors", pos, 1);
    }

    Variant find_path(Variant from, Variant to) {
        Variant current;
        map<Variant, float> g;
        map<Variant, float> h;
        map<Variant, Variant> cameFrom;
        set<Variant> closed;
        auto compareCoordPriorities = [&] (const Variant& lp, const Variant& rp) {
            return g[lp]+h[lp] > g[rp]+h[rp];
        };
        priority_queue<Variant,vector<Variant>,decltype(compareCoordPriorities)> openqueue(compareCoordPriorities);
        g[from] = 0.0;
        h[from] = _h_score(from, to);
        cameFrom[from] = from;
        openqueue.push(from);
        while (!openqueue.empty()) {
            current = openqueue.top();
            openqueue.pop();
            if (current == to) {
                Array path;
                do {
                    path.push_front(current);
                    current = cameFrom[current];
                } while (cameFrom.find(current)!=cameFrom.end());
                return path;
            }
            closed.insert(current);
            Array neighbors = _neighbors(current);
            for (int i=0; i<neighbors.size(); i++) {
                Variant pos = neighbors[i];
                if (closed.find(pos)!=closed.end()) {
                    continue;
                }
                if (!_is_passable(pos)) {
                    continue;
                }
                int tmp_g = g[pos] + _g_score(current, pos);
                cameFrom[pos] = current;
                h[current] = _h_score(pos, to);

                if (g.find(current) == g.end()) {
                    openqueue.push(current);
                    if (tmp_g < g[current]) {
                        g[current] = tmp_g;
                    }
                }
            }
        }
        return Variant();
    }

    static void _register_methods() {
       register_method("find_path", &Pathfinder::find_path);
   
   /**
    * How to register exports like gdscript
    * export var _name = "SimpleClass"
    **/
   register_property((char *)"base/name", &Pathfinder::_name, String("Pathfinder"));
   register_property((char *)"base/love", &Pathfinder::_name, String("Pathfinder"));

       /** For registering signal **/
       // register_signal<SimpleClass>("signal_name");
       // register_signal<SimpleClass>("signal_name", "string_argument", GODOT_VARIANT_TYPE_STRING)
    }

	String _name;
};

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o)
{
    Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o)
{
    Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle)
{
    Godot::nativescript_init(handle);

    register_class<Pathfinder>();
}
