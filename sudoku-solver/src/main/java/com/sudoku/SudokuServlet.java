package com.sudoku;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/api/*")
public class SudokuServlet extends HttpServlet {
    private SudokuGenerator generator;
    private Gson gson;
    
    @Override
    public void init() {
        generator = new SudokuGenerator();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "running");
        response.put("algorithm", "Dancing Links (Algorithm X)");
        out.print(gson.toJson(response));
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        String path = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        try {
            if ("/generate".equals(path)) {
                int[][] puzzle = generator.generatePuzzle(30);
                Map<String, Object> response = new HashMap<>();
                response.put("puzzle", puzzle);
                response.put("status", "success");
                out.print(gson.toJson(response));
                
            } else if ("/solve".equals(path)) {
                String body = req.getReader().lines().collect(Collectors.joining());
                Map<String, Object> requestData = gson.fromJson(body, 
                    new TypeToken<Map<String, Object>>(){}.getType());
                
                List<List<Double>> puzzleList = (List<List<Double>>) requestData.get("puzzle");
                
                int[][] puzzle = new int[9][9];
                for (int i = 0; i < 9; i++) {
                    List<Double> row = puzzleList.get(i);
                    for (int j = 0; j < 9; j++) {
                        puzzle[i][j] = row.get(j).intValue();
                    }
                }
                
                DancingLinksSolver solver = new DancingLinksSolver();
                int[][] solution = new int[9][9];
                for (int i = 0; i < 9; i++) {
                    System.arraycopy(puzzle[i], 0, solution[i], 0, 9);
                }
                
                boolean solved = solver.solve(solution);
                List<List<Integer>> steps = solver.getSteps();
                
                Map<String, Object> response = new HashMap<>();
                response.put("solved", solved);
                response.put("solution", solution);
                response.put("steps", steps);
                response.put("status", "success");
                
                out.print(gson.toJson(response));
            } else {
                resp.setStatus(404);
                out.print("{\"error\": \"Endpoint not found\"}");
            }
        } catch (Exception e) {
            resp.setStatus(500);
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            out.print(gson.toJson(error));
        }
    }
}
