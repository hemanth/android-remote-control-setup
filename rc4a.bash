#!/usr/bin/bash
# License : GPLv3
# Author  : hemanth.hm <hemanth.hm@gmail.com>
# Site    : h3manth.com
# Purpose : Remote control android setup process 

function check_sudo(){
    # Check if the user has sudo privilages 
    sudo -v >/dev/null 2>&1 || { echo $(whoami) has no sudo privileges ; exit 1; }
}

function setup(){

    # Check if the use have sudo privileges, if fine, move on.
    check_sudo

    # Get the latest version of android SDK.
    echo -e "Download and extracting the latest version of android sdk to /opt dir\n"
    (
        cd /opt
    
        curl -s $(curl -s "http://developer.android.com/sdk/index.html" | grep -o -E 'href="([^"#]+).tgz"' | cut -d'"' -f2) | tar xz && echo "Completed download of sdk" || echo "Unable to download the SDK!" 
        # exit has the download did not happen
        exit 1
    
        cd android-sdk-linux
    
        echo -e "\nUpdating SDK and fetching tools..."
        tools/android update sdk -o --no-ui \
        --filter platform,platform-tool,tool,system-image
        echo -e "\nDone updating!"
    
        echo -e "\nAppending PATH to have android sdk tools"
        echo "PATH=\"\${PATH}:~/android-sdk-linux/tools\"" >> ~/.bashrc
    
        # Source ~/.bahrc so that the path is updated
        source ~/.bashrc

        # Start server
        sudo ./adb kill-server && sudo ./adb start-server

        echo -e "\n Almost done, now start a public/private server on your phone. Note : If private server phone must be connected via USB."
        
        # As of now, not worrying about validating IP, cause the users who will be using this script will be sane enough to give the right IP :)
        read -p "Enter IP:PORT of the server which is running on your phone" FIP
        
        # Extract IP and PORT from the value read above.
        local IP   = $( echo FIP | cut -f1 -d":") 
        local PORT = $( echo FIP | cut -f2 -d":")
        
        # Port forwarding
        sudo ./adb forward tcp:9999 tcp:$PORT
       
        # Export host and port  
        [[ ! -z $IP ]] && export AP_HOST = $IP
        [[ ! -z $PORT ]] && export AP_PORT = $PORT
 
        # Get the site_package location
        site_package_path = $(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
        
        # Get SLA4's android.py
        echo -e "\n Getting SLA4's android.py to $site_package_path"
        curl -s "http://android-scripting.googlecode.com/hg/python/ase/android.py" > $site_package_path/android.py
    )
}

echo -e "Starting the setup...\n"
setup
echo -e "Done with the setup! import android and explore!"

