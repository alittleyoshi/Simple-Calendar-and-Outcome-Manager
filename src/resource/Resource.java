package resource;

import java.net.URL;

public abstract class Resource {
    public static URL getResource(String name) {
        return Resource.class.getResource(name);
    }

    protected Resource() {}
}
