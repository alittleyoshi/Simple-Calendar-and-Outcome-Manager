import database.DatabaseManager;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;
import ui.MainPane;

import java.util.Objects;

public class App extends Application {
    static {
        DatabaseManager.initialize();
    }
    public static void main(String[] args) {
        launch(args);
    }
    @Override
    public void start(Stage primaryStage) throws Exception {
//        FXMLLoader loader = new FXMLLoader(App.class.getResource("/ui/main scene.fxml"));
//        Parent parent = loader.load();
//        Scene scene = new Scene(parent, parent.prefWidth(-1), parent.prefHeight(-1), true);
//        scene.getStylesheets().add(Objects.requireNonNull(App.class.getResource("/ui/main style.css")).toExternalForm());
//        primaryStage.setScene(scene);
//        primaryStage.show();
        Scene scene = new Scene(new MainPane());
        primaryStage.setScene(scene);
        primaryStage.setTitle("Simple Calender And Outcome Manager");
        primaryStage.show();
    }
}
