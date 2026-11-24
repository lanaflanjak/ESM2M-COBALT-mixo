import os
import subprocess

# Current working directory
directory = os.getcwd()

#previous = 1860;
# Take command line argument for previous decade
previous = int(input('Enter the starting decade: '))

# For loop to check each folder, in numerical order

for decade in sorted(os.listdir(directory)):
    decade_path = os.path.join(directory, decade)
    print(f'Checking folder {decade}...')
    if len(os.listdir(decade_path)) == 23:
        print(f'      Folder {decade} contains 23 files.')
    else: 
        print(f'!!!! Folder {decade} does not contain 23 files.')
        break
        
    # Save current decade path (i.e. 1940 in the file 1940.01.01_to_1950.01.01)
    current = int(decade.split('.')[0])
    if current == previous:
        print(f'      End of decade matches previous decade.')
    else:
        print(f'!!!! End of decade does not match previous decade.')
        break
    
    # Save previous decade path (i.e. 1950 in the file 1940.01.01_to_1950.01.01)     
    previous = int(decade.split('_')[-1].split('.')[0])
    
    for filename in os.listdir(decade_path):
        if filename.endswith('.nc'):
            file_path = os.path.join(decade_path, filename)
            try:
                # Use ncdump to check if the file is valid
                subprocess.check_output(['ncdump', '-h', file_path], stderr=subprocess.STDOUT)
                print(f'        File {filename} is not corrupted.')
            except subprocess.CalledProcessError:
                print(f'!!!! File {filename} is corrupted.')
                break


