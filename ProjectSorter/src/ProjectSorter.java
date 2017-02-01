import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ProjectSorter {

    private List<String> sortedProjects;
    private Map<String, Project> projectMap = new HashMap<String, Project>();
    private String projectsDir;

    private String projectIdentifier = "";

    private final static String DEPEND_FILE_NAME = "depends.txt";

    private class Project {
        public final String name;
        private boolean sorted = false;

        private List<Project> dependencies;

        Project(String name) {
            this.name = name;
        }

        public List<Project> getDependencies() {
            return dependencies;
        }

        public boolean isSorted() {
            return sorted;
        }

        public void setSorted(boolean sorted) {
            this.sorted = sorted;
        }

        public void addDependency(Project project) {
            if (dependencies == null) {
                dependencies = new LinkedList<Project>();
            }

            dependencies.add(project);
        }
    }

    public ProjectSorter(String projectsDir, String identifier) {
        this.projectsDir = projectsDir;
        this.projectIdentifier = identifier;
    }

    public List<String> getProjects() {

        sortedProjects = new LinkedList<String>();

        findProjects(projectsDir);

        List<Project> projects = new ArrayList<Project>(projectMap.values());
        for (Project project : projects) {
            sortProject(project);
        }

        return sortedProjects;
    }

    private void sortProject(Project project) {
        try {
            if (!project.isSorted()) {
                if (project.getDependencies() == null) {
                    project.setSorted(true);
                    sortedProjects.add(project.name);
                } else {
                    List<Project> deps = project.getDependencies();
                    for (Project dependencyProj : deps) {
                        sortProject(dependencyProj);
                    }

                    project.setSorted(true);
                    sortedProjects.add(project.name);
                }
            }
        } catch (StackOverflowError e) {
            System.out.println(String.format("ERROR: Maybe a circular dependency with '%s' involved", project.name));
            System.exit(-1);
        }
    }

    private void findProjects(String dir) {
        File folder = new File(dir);
        File[] files = folder.listFiles();
        for (File file : files) {
            if (file.isDirectory() && isProjectDir(file, projectIdentifier)) {
                String projectName = file.getName();
                Project project = new Project(projectName);
                projectMap.put(projectName, project);
            }
        }

        List<Project> projects = new ArrayList<Project>(projectMap.values());
        addDependencies(projects);

    }

    private void addDependencies(List<Project> projects) {
        for (Project project : projects) {

            File f = new File(projectsDir + "/" + project.name + "/" + DEPEND_FILE_NAME);

            if (f.exists()) {
                List<String> depnds = parseDepends(f);
                for (String depName : depnds) {
                    Project p = projectMap.get(depName);
                    if (p == null) {
                        System.out.println(String.format("ERROR: Unable to find dependency project '%s' from '%s'. Check your %s.",
                                depName, project.name, DEPEND_FILE_NAME));
                        System.exit(-1);
                    }
                    project.addDependency(p);
                }
            }
        }
    }

    private boolean isProjectDir(File dir, String suffix) {

        File[] files = dir.listFiles();

        boolean result = false;

        for (File file : files) {
            if (file.getName().contains(suffix)) {
                result = true;
                break;
            }
        }

        return result;
    }

    private List<String> parseDepends(File f) {

        List<String> lines = null;

        try {
            lines = Files.readAllLines(Paths.get(f.getAbsolutePath()), StandardCharsets.UTF_8);
        } catch (IOException e) {
            System.out.println(String.format("ERROR: Unable to read '%s'", f.getAbsolutePath()));
            System.exit(-1);
        }

        return lines;
    }
}
