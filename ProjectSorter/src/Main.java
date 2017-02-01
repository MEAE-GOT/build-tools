import java.util.List;

public class Main {

    public static void main(String[] args) {

        if (args.length > 1) {
            String projectRepo = args[0];
            String identifier = args[1];

            ProjectSorter sorter = new ProjectSorter(projectRepo, identifier);

            List<String> projects = sorter.getProjects();

            for (String p : projects) {
                System.out.println(p);
            }
        } else {
            System.out.println("  Usage: ProjectSorter <projectRepo> <project identifier>");
            System.out.println("example: ProjectSorter /home/myQtProjects .pro");
        }
    }

}
