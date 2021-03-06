------

### FIFO_MIG_BASED

IP-ядро, реализующее Fifo на основе DDR памяти и MIG c Native Interface

------

#### Иерархия файлов

- doc - документация на ядро
- hdl - исходные файлы и тесты на HDL
  - header - заголовочные файлы
  - source - файлы исходников
  - testbench - тесты
  - project_top - топ-файлы для демонстрационных проектов
- constraints - файлы ограничений для демонстрационных проектов
- ips - xcix-файлы внутренних IP-ядер
- tcl - скрипты для запуска тестов, упаковки ядра и сборки демонстрационных проектов
- wavedrom - временные диаграммы
- yEd - блок-схемы

------

#### Запуск тестов

Необходимо запустить Vivado Tcl Shell, перейти директорию, где расположен README файл, и запустить тесты с помощью представленных ниже выражений:

- Тесты для проверки режима x4: 

  ```
  vivado -mode batch –source tcl/run_tests_x4.tcl -notrace
  ```

- Тесты для проверки режима x2: 

  ```
  vivado -mode batch –source tcl/run_tests_x2.tcl -notrace
  ```


- Запуск всех тестов: 

  ```
  vivado -mode batch –source tcl/run_all_tests.tcl -notrace
  ```

Результаты тестов, появятся в папке log_log_fifo_mig_based_tests.  Test_Results - краткий отчет. Test_Logs - подробный список ошибок.

------

#### Упаковка ядра из исходников

Необходимо запустить Vivado Tcl Shell, перейти в директорию, где расположен README файл, и запустить скрипт с помощью представленного ниже выражения:

```
vivado -mode batch –source tcl/package_IP.tcl -notrace
```

Упакованное ядро, появится в папке IP.  Эту папке нужно добавить в IP репозиторий проекта.

------

#### Создание демонстрационных проектов

Необходимо запустить Vivado Tcl Shell, перейти в директорию, где расположен README файл, и запустить скрипт с помощью представленного ниже выражения:

```
vivado -mode batch –source tcl/example_project.tcl -notrace
```

После выполнения скрипта, необходимо в Vivado Tcl Shell ввести 

```
open_project fifo_mig_based_example/fifo_mig_based_example.xpr
start_gui
```

