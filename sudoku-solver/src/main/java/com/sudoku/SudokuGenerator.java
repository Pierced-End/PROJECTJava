package com.sudoku;

import java.util.Random;

public class SudokuGenerator {
    private static final int SIZE = 9;
    private Random random;
    
    public SudokuGenerator() {
        this.random = new Random();
    }
    
    public int[][] generatePuzzle(int clues) {
        int[][] solution = generateFullGrid();
        int[][] puzzle = new int[SIZE][SIZE];
        
        for (int i = 0; i < SIZE; i++) {
            System.arraycopy(solution[i], 0, puzzle[i], 0, SIZE);
        }
        
        int cellsToRemove = SIZE * SIZE - clues;
        while (cellsToRemove > 0) {
            int row = random.nextInt(SIZE);
            int col = random.nextInt(SIZE);
            if (puzzle[row][col] != 0) {
                puzzle[row][col] = 0;
                cellsToRemove--;
            }
        }
        
        return puzzle;
    }
    
    private int[][] generateFullGrid() {
        int[][] grid = new int[SIZE][SIZE];
        fillGrid(grid);
        return grid;
    }
    
    private boolean fillGrid(int[][] grid) {
        int[] cells = new int[SIZE * SIZE];
        for (int i = 0; i < cells.length; i++) {
            cells[i] = i;
        }
        shuffle(cells);
        
        for (int cell : cells) {
            int row = cell / SIZE;
            int col = cell % SIZE;
            
            if (grid[row][col] == 0) {
                int[] numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9};
                shuffle(numbers);
                
                for (int num : numbers) {
                    if (isSafe(grid, row, col, num)) {
                        grid[row][col] = num;
                        if (isComplete(grid) || fillGrid(grid)) {
                            return true;
                        }
                        grid[row][col] = 0;
                    }
                }
                return false;
            }
        }
        return isComplete(grid);
    }
    
    private boolean isSafe(int[][] grid, int row, int col, int num) {
        for (int x = 0; x < SIZE; x++) {
            if (grid[row][x] == num || grid[x][col] == num) {
                return false;
            }
        }
        
        int boxRow = row - row % 3;
        int boxCol = col - col % 3;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if (grid[boxRow + i][boxCol + j] == num) {
                    return false;
                }
            }
        }
        return true;
    }
    
    private boolean isComplete(int[][] grid) {
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                if (grid[i][j] == 0) return false;
            }
        }
        return true;
    }
    
    private void shuffle(int[] array) {
        for (int i = array.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }
}
