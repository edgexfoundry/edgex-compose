## Important Dot Release Note (1.0.0 -> 1.0.1)
The Edinburgh 1.0.0 Docker Compose file was removed from this directory.  It used core, supporting, export and other 
    1.0.0 containers which contained a race condition.  Use the 1.0.1 Docker Compose file to get the same 1.0.0 
    functionality but with the critical race condition bugs removed.
